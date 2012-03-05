require 'spec_helper'

describe "Session" do
  before :each do
    @user = Factory(:user, password: '1234', password_confirmation: '1234')
  end

  describe "GET /sign-in" do
    it "should sign the user in with correct credentials" do
      visit sign_in_path
      fill_in('Username', with: @user.username)
      fill_in('Password', with: '1234')
      click_button('Sign In')
      page.should have_content('Sign Out')
    end

    it "should report an error with the incorrect credentials" do
      visit sign_in_path
      fill_in('Username', with: @user.username)
      fill_in('Password', with: '2345')
      click_button('Sign In')
      page.should have_content('Invalid username or password')
    end
  end

  describe "GET /sign-out" do
    it "shold sign the user out" do
      visit sign_in_path
      fill_in('Username', with: @user.username)
      fill_in('Password', with: '1234')
      click_button('Sign In')
      click_link('Sign Out')
      page.should have_content('Sign In')
    end
  end
end