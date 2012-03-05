require 'spec_helper'

describe "Users" do
  describe "GET /profile" do
    it "should include the full name" do
      @user = Factory(:user, password: '1234', password_confirmation: '1234')
      visit sign_in_path
      fill_in('Username', with: @user.username)
      fill_in('Password', with: '1234')
      click_button('Sign In')
      visit profile_path
      page.should have_content(@user.full_name)
    end
  end
end