class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    @budgets = current_user.budgets.includes(:expenses)
  end
end
