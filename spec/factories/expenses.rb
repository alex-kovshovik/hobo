# frozen_string_literal: true

require "factory_bot"

FactoryBot.define do
  factory :expense do
    budget
    date { Date.current }
    amount { 10 }
  end
end
