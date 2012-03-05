require 'spec_helper'
require 'fakeweb'

describe PasswordResetMailer do
  it "should email password reset instructions" do
    user = Factory(:user)
    PasswordResetMailer.perform(user.id)
    body = ActionMailer::Base.deliveries.last.body
    body.should include 'To reset your password'
  end
end