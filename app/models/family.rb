class Family < ApplicationRecord
  belongs_to :owner, class_name: "User"

  has_many :users, dependent: :destroy
  has_many :budgets, dependent: :destroy
end
