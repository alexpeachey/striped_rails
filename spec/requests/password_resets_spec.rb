require 'spec_helper'

describe "PasswordResets" do
  context "when resetting a password" do
    it "should reply positive with bad email" do
      user = Factory(:user, email: 'one@example.com')
      visit new_password_reset_path
      fill_in('Email', with: 'two@example.com')
      click_on('Request')
      page.should have_content('Instructions have been sent to your email.')
    end

    it "should reply positive with good email" do
      user = Factory(:user, email: 'one@example.com')
      visit new_password_reset_path
      fill_in('Email', with: 'one@example.com')
      click_on('Request')
      page.should have_content('Instructions have been sent to your email.')
    end

    it "should allow reset with a valid token" do
      user = Factory(:user, email: 'one@example.com')
      #Fake as if we had done a reset and the email was sent.
      REDIS.set "password_tokens:123456", user.id
      visit edit_password_reset_path(id: '123456')
      page.should have_content("Updating password for #{user.username}")
    end
  end
end