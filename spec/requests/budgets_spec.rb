# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Budgets", type: :request do
  let(:family) { create(:family) }
  let(:user) { create(:user, family: family) }
  let(:user_session) { user.sessions.create!(user_agent: "RSpec", ip_address: "127.0.0.1") }
  let!(:budget) { create(:budget, family: family, name: "Groceries", amount: 500) }

  def sign_in
    post session_path, params: { email_address: user.email_address, password: "hobopass" }
  end

  before do
    sign_in unless RSpec.current_example.metadata[:skip_sign_in]
  end

  describe "GET /budgets" do
    it "returns a successful response" do
      get budgets_path

      expect(response).to have_http_status(:success)
    end

    it "displays the budgets" do
      get budgets_path

      expect(response.body).to include("Groceries")
    end
  end

  describe "GET /budgets/:id/edit" do
    it "returns a successful response" do
      get edit_budget_path(budget)

      expect(response).to have_http_status(:success)
    end

    it "displays the budget form" do
      get edit_budget_path(budget)

      expect(response.body).to include("Edit Budget")
      expect(response.body).to include("Groceries")
    end

    context "when budget belongs to another family" do
      let(:other_family) { create(:family) }
      let(:other_budget) { create(:budget, family: other_family) }

      it "returns not found" do
        get edit_budget_path(other_budget)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /budgets/:id" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Food", amount: 600, icon: "utensils" } }

      it "updates the budget" do
        patch budget_path(budget), params: { budget: new_attributes }

        budget.reload
        expect(budget.name).to eq("Food")
        expect(budget.amount).to eq(600)
        expect(budget.icon).to eq("utensils")
      end

      it "redirects to the budgets index" do
        patch budget_path(budget), params: { budget: new_attributes }

        expect(response).to redirect_to(budgets_path)
      end
    end

    context "when budget belongs to another family" do
      let(:other_family) { create(:family) }
      let(:other_budget) { create(:budget, family: other_family) }

      it "returns not found" do
        patch budget_path(other_budget), params: { budget: { name: "Hacked" } }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "authentication", :skip_sign_in do
    it "redirects to login when not authenticated" do
      get budgets_path

      expect(response).to redirect_to(new_session_path)
    end
  end
end
