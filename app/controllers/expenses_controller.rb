class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def create
    expense = Expense.new(params.require(:expense).permit(:budget_id, :amount))
    expense.budget.family = current_user.family
    expense.save!

    # Render Turbo Frame
  end
end
