# i.e. config/initializers/honeybadger.rb
Honeybadger.configure do |config|
  config.api_key = ENV.fetch("HONEYBADGER_API_KEY", "")
  config.env = Rails.env
  config.root = Rails.root.to_s

  config.development_environments = %w[development test]
  config.debug = false
end
