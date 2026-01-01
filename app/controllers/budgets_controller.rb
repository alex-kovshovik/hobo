# frozen_string_literal: true

class BudgetsController < ApplicationController
  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current.beginning_of_month
    @budgets = Current.user.family.budgets.map { BudgetPresenter.new(it, @date) }
  end
end
