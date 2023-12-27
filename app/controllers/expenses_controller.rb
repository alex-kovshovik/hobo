class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    @budgets = load_budgets
  end

  private

  def load_budgets
    current_user.family.budgets
      .select("budgets.*, SUM(expenses.amount) AS spent")
      .left_joins(:expenses)
      .where("expenses.id is NULL OR (expenses.date >= ? AND expenses.date <= ?)", Date.new(2023, 12, 1), Date.new(2023, 12, 31))
      .group("budgets.id")
  end
end
