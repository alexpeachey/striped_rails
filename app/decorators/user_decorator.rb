class UserDecorator < ApplicationDecorator
  decorates :user

  def signed_in?
    model.id?
  end

  def session_control
    if signed_in?
      h.link_to 'Sign Out', h.sign_out_path
    else
      h.link_to 'Sign In', h.sign_in_path
    end
  end

  def page_editor(page)
    if user.is_admin?
      h.content_tag(:div, class: 'well') do
        h.link_to 'Edit', h.edit_page_path(page)
      end
    end
  end

  def home_link(brand)
    h.link_to brand, home_path, class: 'brand pull-left'
  end

  def home_path
    if is_admin?
      h.dashboard_path
    elsif signed_in?
      h.profile_path
    else
      h.root_path
    end
  end

  def subscription_plan_button(subscription_plan)
    if is_admin?
      h.link_to 'Edit', h.edit_subscription_plan_path(subscription_plan), class: 'btn btn-danger'
    elsif signed_in? && user.subscription_plan_id == subscription_plan.id
      h.link_to 'Your Plan', h.profile_path, class: 'btn btn-success'
    elsif signed_in?
      h.link_to 'Switch To', h.subscription_path(subscription_plan_id: subscription_plan.vault_token), method: 'put', :confirm => 'Are you sure you want to switch plans? Note, your next bill will be prorated.', class: 'btn btn-primary'
    else
      h.link_to 'Sign Up', h.sign_up_path(subscription_plan.vault_token), class: 'btn btn-primary'
    end
  end

  def subscription_content
    if user.subscription_active?
      "Here is your valuable subscription only content."
    else
      h.content_tag(:span, "You are currently not under a plan.", class: "label label-important") +
      h.content_tag(:p, h.link_to("Pick a Plan", h.available_subscription_plans_path, class: "btn btn-danger"))
    end
  end

  def overage_cost
    h.number_to_currency(user.overage_cost.to_f / 100)
  end

  def subscription_plan_name
    if user.subscription_plan_id?
      user.subscription_plan.name
    else
      "No Active Plan"
    end
  end

  def current_subscription_plan_name
    if user.current_status
      user.current_status.subscription.plan.name
    else
      "Missing From Vault"
    end
  end

  def current_subscription_status
    if user.current_status
      user.current_status.subscription.status
    else
      "Missing From Vault"
    end
  end

  def current_period
    if user.current_status
      Time.at(user.current_status.subscription.current_period_start).strftime("%Y-%m-%d") +
      " through " +
      Time.at(user.current_status.subscription.current_period_end).strftime("%Y-%m-%d")
    else
      "Missing From Vault"
    end
  end

  def current_coupon
    if user.current_status
      if user.current_status.respond_to?(:discount)
        user.current_status.discount.coupon.id +
        ' - ' +
        user.current_status.discount.coupon.percent_off.to_s +
        '% valid ' +
        Time.at(user.current_status.discount.start).strftime("%Y-%m-%d") +
        ' through ' +
        Time.at(user.current_status.discount.end).strftime("%Y-%m-%d")
      else
        "No Coupon"
      end
    else
      "Missing From Vault"
    end
  end

  def next_charge
    if user.current_status
      h.number_to_currency(user.current_status.next_recurring_charge.amount.to_f / 100) +
      " on " +
      user.current_status.next_recurring_charge.date
    else
      "Missing From Vault"
    end
  end

  def to_i
    model.to_i
  end

end