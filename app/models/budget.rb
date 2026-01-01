# frozen_string_literal: true

class Budget < ApplicationRecord
  belongs_to :family, touch: true
  has_many :expenses, dependent: :destroy

  def cache_key_with_date(date)
    "#{cache_key_with_version}/#{date.strftime('%Y-%m')}"
  end

  def broadcast_update(date)
    return if Rails.env.test?

    broadcast_render_to family, partial: "budgets/update", locals: { budget: self, date: date }
  end
end
