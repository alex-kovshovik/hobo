# Run using bin/ci

CI.run do
  step "Setup: Test database", "env RAILS_ENV=test bin/rails db:prepare"
  step "Style: Ruby and Shovik cops", "bin/rubocop"
  step "Tests: Shovik cops", "bin/rspec spec/lib/rubocop"
  step "Security: Brakeman", "bin/brakeman --quiet --no-pager --exit-on-warn"
  step "Tests: RSpec", "bin/rspec"
end
