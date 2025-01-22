# frozen_string_literal: true

class Budget < ApplicationRecord
  belongs_to :family

  has_many :expenses, dependent: :destroy

  def broadcast_update(date)
    return if Rails.env.test?

    month = date.beginning_of_month
    found_budget = FamilyBudgetsQuery.new(family).call(month, budget_id: id).first
    presented_budget = BudgetPresenter.new(found_budget, month)

    broadcast_render_to family, month: month, partial: "budgets/update", locals: { budget: presented_budget }
  end
end
