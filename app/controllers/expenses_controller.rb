# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :find_budget

  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current.beginning_of_month
    @expenses = @budget.expenses.with_creator.for_month(@date).ordered
  end

  def create
    @budget.expenses.create!(amount: expense_amount, date: expense_date)

    render json: {}, status: :created
  end

  def destroy
    expense = @budget.expenses.find(params[:id])
    expense.destroy!

    redirect_to date_budget_expenses_path(@budget, expense.date.beginning_of_month)
  end

  private

  def find_budget
    @budget = Budget.find(params[:budget_id])
  end

  def expense_amount
    expense_params[:digits].to_i
  end

  def expense_date
    Date.parse(expense_params[:date])
  end

  def expense_params
    params.require(:expense).permit(:budget_id, :digits, :date)
  end
end
