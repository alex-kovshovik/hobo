# frozen_string_literal: true

class BudgetPresenter < SimpleDelegator
  def initialize(budget, date)
    super(budget)

    @budget = budget
    @date = date
  end

  def total_spent
    @total_spent ||= calculate_total_spent
  end

  def percent_spent
    (total_spent.to_f / budget.amount) * 100
  end

  def percent_of_month
    return 100 if date != Date.current.beginning_of_month

    (Date.current.day / Date.current.end_of_month.day.to_f) * 100
  end

  attr_reader :date

  private

  attr_reader :budget

  def calculate_total_spent
    start_date = date.beginning_of_month
    end_date = date.end_of_month

    expenses.where(date: start_date..end_date).sum(:amount)
  end
end
