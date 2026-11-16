# frozen_string_literal: true

require_relative "cop_spec_helper"

RSpec.describe RuboCop::Cop::Shovik::RescueNonException, :config do
  let(:cop_config) { { "NonExceptionConstants" => ["Timeout", "Net::SMTP", "JSON", "String"] } }

  it "flags rescuing a namespace or value class" do
    expect_offense(<<~RUBY)
      begin
        deliver
      rescue Timeout, Net::SMTP => e
             ^^^^^^^ `Timeout` is not an exception class; rescue the specific error class instead.
                      ^^^^^^^^^ `Net::SMTP` is not an exception class; rescue the specific error class instead.
        log(e)
      end
    RUBY
  end

  it "ignores exception classes and unknown constants" do
    expect_no_offenses(<<~RUBY)
      begin
        parse
      rescue Timeout::Error, JSON::ParserError, Net::SMTPError, CustomFailure, *ERRORS
        nil
      end
    RUBY
  end
end
