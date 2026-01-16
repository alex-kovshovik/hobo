# frozen_string_literal: true

class Budget < ApplicationRecord
  belongs_to :family, touch: true
  has_many :expenses, dependent: :destroy

  def cache_key_with_date(date)
    "#{cache_key_with_version}/#{date.strftime('%Y-%m')}"
  end

  def broadcast_update(date)
    return if Rails.env.test?

    month_date = date.beginning_of_month

    # Update individual budget card
    broadcast_render_to family, date: month_date, partial: "budgets/update", locals: { budget: self, date: month_date }

    # Update monthly total
    monthly_total = family.budgets
      .joins(:expenses)
      .where(expenses: { date: month_date..month_date.end_of_month })
      .sum("expenses.amount")
    broadcast_render_to family, date: month_date, partial: "budgets/monthly_total_update", locals: { monthly_total: monthly_total, date: month_date }
  end
end
