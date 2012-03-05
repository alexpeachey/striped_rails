require 'spec_helper'

describe "SubscriptionPlans" do
  describe "GET /subscription_plans/available" do
    it "should show available plans" do
      @subscription_plan1 = Factory(:subscription_plan)
      @subscription_plan2 = Factory(:subscription_plan)
      visit available_subscription_plans_path
      page.should have_content(@subscription_plan1.name)
      page.should have_content(@subscription_plan2.name)
    end
  end
end
