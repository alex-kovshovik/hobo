# frozen_string_literal: true

class Budget < ApplicationRecord
  belongs_to :family

  has_many :expenses, dependent: :destroy

  def spent(date = nil)
    # This is a bit of a hack to avoid N+1 queries.
    # If this budget was loaded for a list page, it will have the `spent` attribute set.
    # Otherwise - it is calculated on the fly.
    pre_calculated_spent = read_attribute(:spent)
    return pre_calculated_spent if pre_calculated_spent.present?

    date ||= Date.today.beginning_of_month
    expenses.for_month(date).sum(:amount)
  end
end
