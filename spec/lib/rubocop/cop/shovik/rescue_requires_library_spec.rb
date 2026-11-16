# frozen_string_literal: true

require_relative "cop_spec_helper"

RSpec.describe RuboCop::Cop::Shovik::RescueRequiresLibrary, :config do
  let(:cop_config) do
    {
      "Libraries" => {
        "Net::" => ["net/protocol", "net/http", "net/smtp"],
        "Net::SMTP" => ["net/smtp"],
        "Net::HTTP" => ["net/http", "net/https"],
        "OpenSSL::" => ["openssl"],
        "JSON::" => ["json"]
      }
    }
  end

  it "flags a stdlib error rescued without its require" do
    expect_offense(<<~RUBY)
      def deliver
        mail.deliver_now
      rescue Net::SMTPAuthenticationError, JSON::ParserError
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Net::SMTPAuthenticationError` needs `require "net/smtp"` in this file.
                                           ^^^^^^^^^^^^^^^^^ `JSON::ParserError` needs `require "json"` in this file.
      end
    RUBY
  end

  it "uses the longest matching prefix" do
    expect_offense(<<~RUBY)
      require "net/smtp"

      begin
        fetch
      rescue Net::HTTPBadResponse
             ^^^^^^^^^^^^^^^^^^^^ `Net::HTTPBadResponse` needs `require "net/http"` in this file.
      end
    RUBY
  end

  it "flags rescue_from" do
    expect_offense(<<~RUBY)
      class ApplicationController < ActionController::Base
        rescue_from OpenSSL::SSL::SSLError, with: :retry_later
                    ^^^^^^^^^^^^^^^^^^^^^^ `OpenSSL::SSL::SSLError` needs `require "openssl"` in this file.
      end
    RUBY
  end

  it "accepts any listed require for the prefix" do
    expect_no_offenses(<<~RUBY)
      require "net/smtp"

      begin
        deliver
      rescue Net::SMTPError, Net::ReadTimeout
        retry
      end
    RUBY
  end

  it "ignores constants outside the allowlist" do
    expect_no_offenses(<<~RUBY)
      begin
        find
      rescue ActiveRecord::RecordNotFound, Timeout::Error, *NETWORK_ERRORS
        nil
      end
    RUBY
  end
end
