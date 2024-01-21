require "factory_bot"

FactoryBot.define do
  factory :budget do
    family
    name { "Groceries" }
    icon { "shopping-cart" }
    amount { 100 }
    private { false }
  end
end
