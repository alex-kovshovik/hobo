# frozen_string_literal: true

require "factory_bot"

FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Doe" }
    sequence(:email_address) { |n| "john.doe#{n}@hobo.com" }
    password { "hobopass" }
    association :family
  end
end
