# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :find_budget

  def index
    date_param = params[:date]

    @month = date_param.present? ? Date.parse(date_param) : Date.current.beginning_of_month
    @expenses = @budget.expenses.with_creator.for_month(@month).ordered
  end

  def create
    @budget.expenses.create!(amount: expense_amount)

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

  def expense_params
    params.require(:expense).permit(:budget_id, :digits)
  end
end
