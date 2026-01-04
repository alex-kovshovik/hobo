# frozen_string_literal: true

# Enable CSRF protection for system specs with JavaScript
# This is needed because JavaScript code relies on the CSRF token from meta tags
# The test environment disables CSRF by default, but we need it for JS specs

RSpec.configure do |config|
  # Use prepend: true to ensure this runs before other before hooks
  config.before(:each, type: :system, js: true, prepend: true) do
    ActionController::Base.allow_forgery_protection = true
  end

  # Use append: true to ensure this runs after other after hooks
  config.append_after(:each, type: :system, js: true) do
    ActionController::Base.allow_forgery_protection = false
  end
end
