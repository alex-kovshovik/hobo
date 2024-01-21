# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index; end

  def create
    expense = Expense.new(budget_id: expense_params[:budget_id], amount: expense_amount)
    expense.budget.family = current_user.family
    expense.save!

    render json: {}, status: :created
  end

  private

  def expense_amount
    expense_params[:digits].to_i / 100.0
  end

  def expense_params
    params.require(:expense).permit(:budget_id, :digits)
  end
end
