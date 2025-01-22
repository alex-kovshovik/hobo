# frozen_string_literal: true

require "rails_helper"

describe "FamilyBudgetsQuery" do
  let(:user) { create(:user) }
  let(:family) { create(:family) }
  let(:budget1) { create(:budget, family:) }
  let(:budget2) { create(:budget, family:) }

  before do
    user.update(family:)

    create(:expense, budget: budget1, date: Date.current)
    create(:expense, budget: budget2, date: Date.current)
    create(:expense, budget: budget2, date: Date.current - 1.month)
  end

  context "when budget is not passed in" do
    it "returns family budgets for a given date" do
      result = FamilyBudgetsQuery.new(family).call(Date.current)

      expect(result).to match_array([budget1, budget2])
    end
  end

  context "when budget is passed in" do
    it "returns the specific family budget for a given date" do
      result = FamilyBudgetsQuery.new(family).call(Date.current, budget_id: budget1.id)

      expect(result).to eq([budget1])
    end
  end
end
