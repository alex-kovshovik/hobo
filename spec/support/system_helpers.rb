# frozen_string_literal: true

module SystemHelpers
  def sign_in_as(user, password: "hobopass")
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_button "Sign in"
    expect(page).to have_current_path(root_path)
    visit budgets_path
    # Wait for Stimulus to be ready
    expect(page).to have_css("[data-controller='numpad']")
  end

  def wait_for_turbo
    expect(page).to have_no_css("[data-turbo-preview]")
  end

  def click_budget_button(budget_name)
    find("button[data-action='numpad#budgetPress']", text: budget_name).click
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
