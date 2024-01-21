# frozen_string_literal: true

class BudgetsController < ApplicationController
  before_action :authenticate_user!

  layout false

  def index
    date = params[:date] ? Date.parse(params[:date]) : Date.current
    @budgets = FamilyBudgetsQuery.new(current_user.family).call(date)
  end
end
