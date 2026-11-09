# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Expenses", type: :request do
  let(:family) { create(:family) }
  let(:user) { create(:user, family: family) }
  let!(:budget) { create(:budget, family: family, name: "Groceries") }

  let(:other_family) { create(:family, name: "Strangers") }
  let(:other_user) { create(:user, family: other_family, first_name: "Mallory") }
  let!(:other_budget) { create(:budget, family: other_family, name: "Secret Stash") }
  let!(:other_expense) { create(:expense, budget: other_budget, amount: 4242, creator: other_user) }

  let(:month) { Date.current.beginning_of_month }
  let(:expense_params) { { expense: { digits: "1500", date: Date.current.iso8601, is_refund: "false" } } }

  before do
    post session_path, params: { email_address: user.email_address, password: "hobopass" }
  end

  describe "own family budget" do
    let!(:expense) { create(:expense, budget: budget, amount: 1234, creator: user) }

    it "lists expenses" do
      get date_budget_expenses_path(budget, month)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Groceries")
    end

    it "creates an expense" do
      expect { post budget_expenses_path(budget), params: expense_params }
        .to change { budget.expenses.count }.by(1)

      expect(response).to have_http_status(:created)
    end

    it "destroys an expense" do
      expect { delete budget_expense_path(budget, expense) }
        .to change { Expense.exists?(expense.id) }.from(true).to(false)

      expect(response).to redirect_to(date_budget_expenses_path(budget, month))
    end
  end

  describe "another family's budget" do
    it "does not list its expenses" do
      get date_budget_expenses_path(other_budget, month)

      expect(response).to have_http_status(:not_found)
    end

    it "does not create an expense on it" do
      expect { post budget_expenses_path(other_budget), params: expense_params }
        .not_to change(Expense, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "does not destroy its expenses" do
      expect { delete budget_expense_path(other_budget, other_expense) }
        .not_to change(Expense, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
