# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Month Navigation", type: :system, js: true do
  let(:user) { create(:user) }
  let!(:budget) { create(:budget, family: user.family, name: "Groceries", amount: 500) }

  before do
    sign_in_as(user)
  end

  it "displays the current month" do
    expect(page).to have_content(Date.current.strftime("%B %Y"))
  end

  it "navigates to the previous month" do
    find("a i.fa-arrow-left-long").click

    expected_month = Date.current.prev_month.strftime("%B %Y")
    expect(page).to have_content(expected_month)
  end

  it "navigates to the next month" do
    find("a i.fa-arrow-right-long").click

    expected_month = Date.current.next_month.strftime("%B %Y")
    expect(page).to have_content(expected_month)
  end

  describe "expense totals by month" do
    let!(:expense_this_month) do
      create(:expense, budget: budget, amount: 50, date: Date.current.beginning_of_month + 10.days, creator: user)
    end
    let!(:expense_last_month) do
      create(:expense, budget: budget, amount: 100, date: Date.current.prev_month.beginning_of_month + 10.days, creator: user)
    end

    it "shows current month expenses" do
      visit budgets_path
      expect(page).to have_content("$50")
    end

    it "shows previous month expenses when navigating back", :skip_ci do
      visit budgets_path
      find("a i.fa-arrow-left-long").click

      wait_for_turbo
      expect(page).to have_content("$100")
    end

    it "shows correct expenses when navigating forward then back", :skip_ci do
      visit budgets_path
      find("a i.fa-arrow-right-long").click
      wait_for_turbo
      expect(page).to have_content("$0")

      find("a i.fa-arrow-left-long").click
      wait_for_turbo
      expect(page).to have_content("$50")

      find("a i.fa-arrow-left-long").click
      wait_for_turbo
      expect(page).to have_content("$100")
    end
  end

  describe "URL updates" do
    it "updates URL when navigating to previous month" do
      find("a i.fa-arrow-left-long").click

      expected_date = Date.current.prev_month.beginning_of_month.strftime("%Y-%m-%d")
      expect(page).to have_current_path("/budgets/#{expected_date}")
    end

    it "updates URL when navigating to next month" do
      find("a i.fa-arrow-right-long").click

      expected_date = Date.current.next_month.beginning_of_month.strftime("%Y-%m-%d")
      expect(page).to have_current_path("/budgets/#{expected_date}")
    end
  end

  describe "budget display" do
    it "shows budget in the list" do
      expect(page).to have_content("Groceries")
      expect(page).to have_content("$500")
    end

    it "maintains budget display after month navigation" do
      find("a i.fa-arrow-left-long").click
      wait_for_turbo

      expect(page).to have_content("Groceries")
      expect(page).to have_content("$500")
    end
  end
end
