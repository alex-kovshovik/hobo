# frozen_string_literal: true

require "rails_helper"

describe BudgetPresenter do
  subject do
    found_budget = FamilyBudgetsQuery.new(family).call(month, budget_id: budget.id).first
    described_class.new(found_budget, month)
  end

  let(:family) { create(:family) }
  let(:budget) { create(:budget, family: family, amount: 100) }
  let(:month) { Date.current.beginning_of_month }

  describe "#percent_spent" do
    context "when there are expenses" do
      before do
        create(:expense, budget: budget, amount: 50, date: month)
      end

      it "calculates the percent spent" do
        expect(subject.percent_spent).to eq(50.0)
      end
    end

    context "when there are no expenses" do
      it "returns 0 percent spent" do
        expect(subject.percent_spent).to eq(0.0)
      end
    end
  end

  describe "#percent_of_month" do
    context "when the month is the current month" do
      it "calculates the percent of the month passed" do
        expect(subject.percent_of_month).to be_within(0.1).of((Date.current.day / Date.current.end_of_month.day.to_f) * 100)
      end
    end

    context "when the month is not the current month" do
      let(:month) { Date.current.prev_month.beginning_of_month }

      it "returns 100" do
        expect(subject.percent_of_month).to eq(100)
      end
    end
  end
end
