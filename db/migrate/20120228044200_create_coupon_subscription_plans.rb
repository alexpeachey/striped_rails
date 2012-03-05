class CreateCouponSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :coupon_subscription_plans do |t|
      t.references :coupon
      t.references :subscription_plan

      t.timestamps
    end
    add_index :coupon_subscription_plans, :coupon_id
    add_index :coupon_subscription_plans, :subscription_plan_id
  end
end
