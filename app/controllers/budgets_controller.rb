# frozen_string_literal: true

class BudgetsController < ApplicationController
  before_action :authenticate_user!

  layout false

  def index
    @budgets = FamilyBudgetsQuery.new(current_user.family).call(Date.current)
  end
end
