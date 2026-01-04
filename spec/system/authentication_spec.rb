# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :system do
  let(:user) { create(:user) }

  describe "signing in" do
    it "allows a user to sign in with valid credentials" do
      visit new_session_path

      fill_in "email_address", with: user.email_address
      fill_in "password", with: "hobopass"
      click_button "Sign in"

      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Welcome to HOBO")
    end

    it "shows error message with invalid credentials" do
      visit new_session_path

      fill_in "email_address", with: user.email_address
      fill_in "password", with: "wrongpassword"
      click_button "Sign in"

      expect(page).to have_content("Try another email address or password")
      expect(page).to have_current_path(new_session_path)
    end

    it "shows error message with non-existent email" do
      visit new_session_path

      fill_in "email_address", with: "nobody@example.com"
      fill_in "password", with: "hobopass"
      click_button "Sign in"

      expect(page).to have_content("Try another email address or password")
    end
  end

  describe "authentication requirement" do
    it "redirects unauthenticated users to login" do
      visit budgets_path

      expect(page).to have_current_path(new_session_path)
    end
  end

  describe "signing out", js: true do
    before do
      visit new_session_path
      fill_in "email_address", with: user.email_address
      fill_in "password", with: "hobopass"
      click_button "Sign in"
      expect(page).to have_current_path(root_path)
    end

    it "signs out the user" do
      click_link "Logout"

      expect(page).to have_current_path(new_session_path)
    end

    it "prevents access to protected pages after sign out" do
      click_link "Logout"
      expect(page).to have_current_path(new_session_path)

      # Clear any cached session and try to access protected page
      Capybara.reset_sessions!
      visit budgets_path

      expect(page).to have_current_path(new_session_path)
    end
  end
end
