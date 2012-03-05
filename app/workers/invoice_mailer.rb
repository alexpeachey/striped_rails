class InvoiceMailer
  @queue = :invoice_mailer
  def self.perform(id,invoice)
    user = User.find(id)
    invoice = Stripe::StripeObject.construct_from(JSON.parse(invoice), ENV['STRIPE_API_KEY'])
    UserMailer.invoice(user, invoice).deliver
  end
end