# frozen_string_literal: true

class BudgetsController < ApplicationController
  before_action :set_budget, only: %i[edit update]

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current.beginning_of_month
    @budgets = Current.user.family.budgets.map { BudgetPresenter.new(it, @date) }

    if turbo_frame_request?
      render partial: "budgets", formats: [:html]
    end
  end

  def edit
  end

  def update
    if @budget.update(budget_params)
      redirect_to budgets_path, notice: "Budget updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_budget
    @budget = Current.user.family.budgets.find(params[:id])
  end

  def budget_params
    params.require(:budget).permit(:name, :icon, :amount)
  end
end
