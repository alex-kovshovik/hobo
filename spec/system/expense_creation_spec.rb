# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Expense Creation", type: :system, js: true do
  let(:user) { create(:user) }
  let!(:budget) { create(:budget, family: user.family, name: "Groceries", amount: 500) }

  before do
    sign_in_as(user)
  end

  describe "expense modal" do
    it "opens when clicking Expense button" do
      expect(page).to have_button("Expense")

      click_button "Expense"

      expect(page).to have_css(".modal.is-active")
      expect(page).to have_content("Select Budget:")
    end

    it "closes when clicking the modal background", :skip_ci do
      click_button "Expense"
      expect(page).to have_css(".modal.is-active")

      # Click on the edge of the modal background to avoid the modal content
      find(".modal-background").click(x: 10, y: 10)

      expect(page).to have_no_css(".modal.is-active")
    end

    it "closes when clicking the X button" do
      click_button "Expense"
      expect(page).to have_css(".modal.is-active")

      find(".modal-close").click

      expect(page).to have_no_css(".modal.is-active")
    end

    it "closes when pressing browser back button" do
      click_button "Expense"
      expect(page).to have_css(".modal.is-active")

      page.go_back

      expect(page).to have_no_css(".modal.is-active")
      expect(page).to have_current_path(budgets_path)
    end
  end

  describe "numpad entry" do
    before do
      click_button "Expense"
    end

    it "displays entered digits" do
      click_button "1"
      click_button "2"
      click_button "5"

      within("[data-numpad-target='amount']") do
        expect(page).to have_content("125")
      end
    end

    it "enters all digits 0-9" do
      (1..9).each { |digit| click_button digit.to_s }
      click_button "0"

      within("[data-numpad-target='amount']") do
        expect(page).to have_content("1234567890")
      end
    end

    it "clears amount with CLR button" do
      click_button "5"
      click_button "0"

      within("[data-numpad-target='amount']") do
        expect(page).to have_content("50")
      end

      click_button "CLR"

      within("[data-numpad-target='amount']") do
        expect(page).to have_content("0")
      end
    end

    it "deletes last digit with DEL button" do
      click_button "1"
      click_button "2"
      click_button "5"

      find("button[data-value='DEL']").click

      within("[data-numpad-target='amount']") do
        expect(page).to have_content("12")
      end
    end

    it "shows zero after deleting the only digit" do
      click_button "5"
      find("button[data-value='DEL']").click

      within("[data-numpad-target='amount']") do
        expect(page).to have_content("0")
      end
    end
  end

  describe "creating an expense" do
    # Note: These AJAX tests have test isolation issues when run with the full suite.
    # They pass individually but fail when run together due to CSRF token handling
    # between transactional/non-transactional test modes.

    it "creates expense when selecting a budget with amount entered", :skip_ci do
      click_button "Expense"

      click_button "2"
      click_button "5"

      # Click the budget button
      find("button[data-action='numpad#budgetPress']", text: "Groceries").click

      # Wait for modal to close (AJAX completed)
      expect(page).to have_no_css(".modal.is-active", wait: 5)
      expect(Expense.count).to eq(1)
      expect(Expense.last.amount).to eq(25)
    end

    it "updates budget card after expense creation", :skip_ci do
      click_button "Expense"

      click_button "5"
      click_button "0"

      find("button[data-action='numpad#budgetPress']", text: "Groceries").click

      # Wait for modal to close and budget to update via Action Cable
      expect(page).to have_no_css(".modal.is-active", wait: 5)
      expect(page).to have_content("$50")
    end

    it "does not create expense when no amount is entered" do
      click_button "Expense"

      find("button[data-action='numpad#budgetPress']", text: "Groceries").click

      # Modal should remain open since no amount was entered
      expect(page).to have_css(".modal.is-active")
      expect(Expense.count).to eq(0)
    end

    it "records the current user as the expense creator", :skip_ci do
      click_button "Expense"
      click_button "1"
      click_button "0"
      find("button[data-action='numpad#budgetPress']", text: "Groceries").click

      expect(page).to have_no_css(".modal.is-active", wait: 5)
      expect(Expense.last.creator).to eq(user)
    end
  end

  describe "with multiple budgets", :skip_ci do
    let!(:budget2) { create(:budget, family: user.family, name: "Utilities", amount: 200) }

    it "shows all family budgets in the modal" do
      visit budgets_path
      click_button "Expense"

      expect(page).to have_css("button[data-action='numpad#budgetPress']", text: "Groceries")
      expect(page).to have_css("button[data-action='numpad#budgetPress']", text: "Utilities")
    end

    it "creates expense for the selected budget" do
      visit budgets_path
      click_button "Expense"
      click_button "7"
      click_button "5"
      find("button[data-action='numpad#budgetPress']", text: "Utilities").click

      expect(page).to have_no_css(".modal.is-active", wait: 5)
      expect(Expense.last.budget).to eq(budget2)
      expect(Expense.last.amount).to eq(75)
    end
  end
end
