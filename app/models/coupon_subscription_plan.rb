class CouponSubscriptionPlan < ActiveRecord::Base
  validates_presence_of :coupon_id, :subscription_plan_id
  belongs_to :coupon
  belongs_to :subscription_plan
end
