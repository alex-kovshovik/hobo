# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :budget

  after_initialize :set_default_date

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true

  private

  def set_default_date
    self.date ||= Date.current
  end
end
