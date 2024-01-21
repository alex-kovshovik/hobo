# frozen_string_literal: true

class FamilyBudgetsQuery
  def initialize(family)
    @family = family
  end

  def call(date)
    start_date = date.beginning_of_month
    end_date = date.end_of_month

    family
      .budgets
      .select('budgets.*, SUM(expenses.amount) AS spent')
      .joins("left join expenses on expenses.budget_id = budgets.id and expenses.date between '#{start_date}' and '#{end_date}'")
      .group('budgets.id')
  end

  private

  attr_reader :family
end
