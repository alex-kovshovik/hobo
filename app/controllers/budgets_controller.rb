# frozen_string_literal: true

class BudgetsController < ApplicationController
  before_action :authenticate_user!

  layout false

  def index
    date = params[:date] ? Date.parse(params[:date]) : Date.current.beginning_of_month
    @budgets = FamilyBudgetsQuery.new(current_user.family).call(date)
  end

  def show
    budget = Budget.find(params[:id])
    date_param = params[:date]
    date = date_param.present? ? Date.parse(date_param) : Date.current.beginning_of_month

    @expenses = budget.expenses.with_creator.for_month(date).ordered
  end
end
