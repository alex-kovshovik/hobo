# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :budget, inverse_of: :expenses, touch: true
  belongs_to :creator, class_name: "User", foreign_key: "created_by", optional: true

  after_initialize :set_default_date

  after_commit :broadcast_budget_update

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :with_creator, -> { includes(:creator) }
  scope :for_month, ->(date) { where(date: date.beginning_of_month..date.end_of_month) }

  private

  def set_default_date
    self.date ||= Date.today
  end

  def broadcast_budget_update
    budget.reload.broadcast_update(date)
  end
end
