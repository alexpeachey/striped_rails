require 'spec_helper'

describe "Pages" do
  describe "GET /" do
    context "the top header bar" do
      before :each do
        @page1 = Factory(:page)
        @page2 = Factory(:page)
      end

      it "should have a pages_menu" do
        visit root_path
        page.should have_selector('#top_header #pages_menu')
      end

      it "should list the pages in the pages_menu" do
        visit root_path
        within('#top_header #pages_menu') do
          page.should have_content(@page1.title)
          page.should have_content(@page2.title)
        end
      end

      it "should have a sign in link when not signed in" do
        visit root_path
        within('#top_header #session_control') do
          page.should have_content('Sign In')
        end
      end
    end

    context "the home page" do
      it "should have a hero spot" do
        visit root_path
        page.should have_selector('#main_hero')
      end

      it "should have a secondary action" do
        visit root_path
        page.should have_selector('#all_options')
      end
    end
  end

  describe "GET /slug" do
    it "should show the page with the specified slug" do
      @page = Factory(:page)
      visit page_path(@page)
      page.should have_content(@page.title)
    end
  end
end
