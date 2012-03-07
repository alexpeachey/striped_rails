class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :username
  has_secure_password
  attr_accessor :current_password, :email_confirmation, :username_confirmation, :card_token
  attr_accessible :username, :email, :full_name, :password, :password_confirmation, :subscription_plan_id, :card_token, :coupon_code, :username_confirmation, :email_confirmation
  validates_presence_of :username, :email, :full_name
  validates_presence_of :password, :password_confirmation, on: :create
  validates_length_of :username, in: 1..50
  validates_format_of :username, with: /\A[a-z0-9\-]+\Z/i
  validates_uniqueness_of :username
  validates_length_of :email, in: 1..255
  validates_format_of :email, with: /\A.+@.+\..+\Z/
  validates_uniqueness_of :email
  validates_length_of :full_name, in: 1..255
  belongs_to :subscription_plan, counter_cache: true
  belongs_to :coupon, counter_cache: true
  after_save :update_stripe_customer

  def self.sanitize(field)
    return nil if field.nil?
    field.downcase.strip
  end

  def self.find_by_remember_me_token(token)
    uid = REDIS.zscore "remember_me_tokens", token
    User.find(uid.to_i) if uid.present?
  end

  def self.find_by_forgot_password_token(token)
    uid = REDIS.get "password_tokens:#{token}"
    User.find(uid) if uid.present?
  end

  def username=(val)
    write_attribute(:username, User.sanitize(val))
  end

  def email=(val)
    write_attribute(:email, User.sanitize(val))
  end

  def coupon_code=(val)
    coupon = Coupon.find_by_coupon_code(val)
    if coupon && coupon.subscription_plans.include?(subscription_plan)
      self.coupon = coupon
    end
    
    self.coupon_code
  end

  def coupon_code
    coupon.coupon_code if coupon.present?
  end

  def subscription_active?
    subscription_plan_id?
  end

  def last4
    customer = Stripe::Customer.retrieve(vault_token)
    if customer.active_card.present?
      customer.active_card.last4
    else
      nil
    end
  end

  def current_status
    @current_status ||= Stripe::Customer.retrieve(vault_token) if vault_token

    @current_status
  end

  def unit_usage
    REDIS.get("usage_meters:#{id}").to_i || 0
  end

  def use_unit
    REDIS.incr("usage_meters:#{id}").to_i
  end

  def reset_usage
    REDIS.getset("usage_meters:#{id}", 0).to_i
  end

  def included_units
    if subscription_plan_id? then subscription_plan.included_units else 0 end
  end

  def overage_units
    [unit_usage - included_units, 0].max
  end

  def over_limit?
    overage_units > 0
  end

  def overage_price
    if subscription_plan_id? then subscription_plan.overage_price else 0 end
  end

  def overage_cost
    overage_units * overage_price
  end

  def handle_overage
    if over_limit?
      add_overage_to_bill
    else
      reset_usage
    end
  end

  def remember_me_token
    token = REDIS.hget "users:#{id}", "remember_me_token"
    unless token
      token = generate_remember_me_token
    end
    
    token
  end

  def forgot_password_token(expires = 60*60*2) # 2 Hours
    token = generate_forgot_password_token
    REDIS.set "password_tokens:#{token}", id
    REDIS.expire "password_tokens:#{token}", expires

    token
  end

  def deliver_reset_password_instructions
    Resque.enqueue(PasswordResetMailer, id)
  end

  def create_with_stripe
    if valid?
      customer = Stripe::Customer.create(email: email, description: username, plan: subscription_plan.vault_token, coupon: coupon_code, card: card_token)
      self.vault_token = customer.id
      save!
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe Request error while creating user: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  rescue Stripe::CardError => expires
    logger.error "Stripe Card error while creating user: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  rescue Stripe::AuthenticationError => e
    logger.error "Stripe Authentication error while creating user: #{e.message}"
    errors.add :base, "Our system is temporarily unable to process credit cards."
    false
  rescue Stripe::APIError => e
    logger.error "Stripe Authentication error while creating user: #{e.message}"
    errors.add :base, "Our system is temporarily unable to process credit cards."
    false
  end

  def update_credit_card
    if valid?
      customer = Stripe::Customer.retrieve(vault_token)
      customer.card = card_token
      customer.save
      true
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe Request error while updating card: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  rescue Stripe::CardError => expires
    logger.error "Stripe Card error while updating card: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  rescue Stripe::AuthenticationError => e
    logger.error "Stripe Authentication error while updating card: #{e.message}"
    errors.add :base, "Our system is temporarily unable to process credit cards."
    false
  rescue Stripe::APIError => e
    logger.error "Stripe Authentication error while updating card: #{e.message}"
    errors.add :base, "Our system is temporarily unable to process credit cards."
    false
  end

  def switch_subscription_plan(new_plan)
    customer = Stripe::Customer.retrieve(vault_token)
    customer.update_subscription(plan: new_plan.vault_token)
    self.subscription_plan = new_plan
    save
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe Request error while switching plans: #{e.message}"
    false
  rescue Stripe::AuthenticationError => e
    logger.error "Stripe Authentication error while switching plans: #{e.message}"
    false
  rescue Stripe::APIError => e
    logger.error "Stripe Authentication error while switching plans: #{e.message}"
    false
  end

  def cancel_subscription_plan
    customer = Stripe::Customer.retrieve(vault_token)
    customer.cancel_subscription(at_period_end: true)
    true
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe Request error while canceling plan: #{e.message}"
    false
  rescue Stripe::AuthenticationError => e
    logger.error "Stripe Authentication error while canceling plan: #{e.message}"
    false
  rescue Stripe::APIError => e
    logger.error "Stripe Authentication error while canceling plan: #{e.message}"
    false
  end

  def deliver_invoice(invoice)
    Resque.enqueue(InvoiceMailer, id, invoice)
  end

  def remove_subscription
    self.subscription_plan = nil
    save
  end

  def to_i
    id
  end

  private
  def generate_remember_me_token
    begin
      token = SecureRandom.urlsafe_base64
    end while REDIS.zscore "remember_me_tokens", token
    REDIS.multi do
      REDIS.zadd "remember_me_tokens", id, token
      REDIS.gset "users:#{id}", "remember_me_token", token
    end
    
    token
  end

  def generate_forgot_password_token
    begin
      token = SecureRandom.urlsafe_base64
    end while REDIS.sismember "password_tokens", token
    REDIS.sadd "password_tokens", token

    token
  end

  def update_stripe_customer
    if email_changed? && !id_changed?
      customer = Stripe::Customer.retrieve(vault_token)
      customer.email = email
      customer.save
      true
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while updating user: #{e.message}"
    errors.add :base, "There was a problem updating your information with or credit card processor. Please try again later."
    false
  rescue Stripe::AuthenticationError => e
    logger.error "Stripe error while updating user: #{e.message}"
    errors.add :base, "There was a problem updating your information with or credit card processor. Please try again later."
    false
  rescue Stripe::APIError => e
    logger.error "Stripe error while updating user: #{e.message}"
    errors.add :base, "There was a problem updating your information with or credit card processor. Please try again later."
    false
  end

  def add_overage_to_bill
    billable = (reset_usage - subscription_plan.included_units)
    bill_amount = billable * subscription_plan.overage_price
    Stripe::InvoiceItem.create({
      customer: vault_token,
      amount: bill_amount,
      currency: subscription_plan.currency,
      description: "#{subscription_plan.unit_name} Overage"
    })
    true
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while adding invoiceitem of #{bill_amount} to #{username}: #{e.message}"
    false
  rescue Stripe::AuthenticationError => e
    logger.error "Stripe error while adding invoiceitem of #{bill_amount} to #{username}: #{e.message}"
    false
  rescue Stripe::APIError => e
    logger.error "Stripe error while adding invoiceitem of #{bill_amount} to #{username}: #{e.message}"
    false
  end
end
