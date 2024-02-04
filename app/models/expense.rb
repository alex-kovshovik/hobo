# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :budget

  after_initialize :set_default_date

  belongs_to :creator, class_name: "User", foreign_key: "created_by"

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :with_creator, -> { includes(:creator) }

  private

  def set_default_date
    self.date ||= Date.current
  end
end
