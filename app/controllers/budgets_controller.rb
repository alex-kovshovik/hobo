# frozen_string_literal: true

class BudgetsController < ApplicationController
  before_action :authenticate_user!

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current.beginning_of_month
    @budgets = FamilyBudgetsQuery.new(current_user.family).call(@date)

    render layout: false
  end

  def show
    date_param = params[:date]

    @date = date_param.present? ? Date.parse(date_param) : Date.current.beginning_of_month
    @budget = Budget.find(params[:id])
    @expenses = @budget.expenses.with_creator.for_month(@date).ordered
  end
end
