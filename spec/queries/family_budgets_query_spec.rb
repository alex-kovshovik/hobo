# frozen_string_literal: true

require "rails_helper"

describe "FamilyBudgetsQuery" do
  let(:user) { create(:user) }
  let(:family) { create(:family, owner: user) }
  let(:budget) { create(:budget, family:) }

  before do
    user.update(family:)

    create(:expense, budget:, date: Date.current)
    create(:expense, budget:, date: Date.current - 1.month)
  end

  it "returns family for a given date" do
    result = FamilyBudgetsQuery.new(family).call(Date.current)

    expect(result).to eq([budget])
  end
end
