class CouponDecorator < ApplicationDecorator
  decorates :coupon

  def percent_off
    "#{coupon.percent_off}% Off"
  end

  def expiration
    coupon.redeem_by.strftime("%Y-%m-%d")
  end

  def applicable_plans
    coupon.subscription_plans.map {|p| p.name}.join(',')
  end
end