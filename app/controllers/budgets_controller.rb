# frozen_string_literal: true

class BudgetsController < ApplicationController
  def index
    @month = params[:date] ? Date.parse(params[:date]) : Date.current.beginning_of_month
    @budgets = FamilyBudgetsQuery.new(Current.user.family).call(@month).map { |budget| BudgetPresenter.new(budget, @month) }
  end
end
