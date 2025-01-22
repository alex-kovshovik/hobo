# frozen_string_literal: true

class BudgetPresenter < SimpleDelegator
  def initialize(budget, month)
    super(budget)

    @budget = budget
    @month = month
  end

  def percent_spent
    (budget.spent.to_f / budget.amount) * 100
  end

  def percent_of_month
    return nil if month != Date.current.beginning_of_month

    (Date.current.day / Date.current.end_of_month.day.to_f) * 100
  end

  attr_reader :month

  private

  attr_reader :budget
end
