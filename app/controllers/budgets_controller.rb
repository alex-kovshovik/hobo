# frozen_string_literal: true

class BudgetsController < ApplicationController
  before_action :authenticate_user!

  def index
    @month = params[:date] ? Date.parse(params[:date]) : Date.current.beginning_of_month
    @budgets = FamilyBudgetsQuery.new(current_user.family).call(@month)
  end
end
