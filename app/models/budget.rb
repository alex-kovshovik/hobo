# frozen_string_literal: true

class Budget < ApplicationRecord
  belongs_to :family

  has_many :expenses, dependent: :destroy
end
