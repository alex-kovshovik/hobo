# frozen_string_literal: true

class Family < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :budgets, dependent: :destroy
end
