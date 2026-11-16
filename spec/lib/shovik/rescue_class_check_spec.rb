# frozen_string_literal: true

require "rails_helper"

describe Shovik::RescueClassCheck do
  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  before do
    stub_const("ShovikProbe::Error", Class.new(StandardError))
    stub_const("ShovikProbe::Response", Class.new)
    stub_const("ShovikProbe::Retryable", Module.new)
    stub_const("ShovikProbe::RetryableError", Class.new(StandardError).tap { |klass| klass.include(ShovikProbe::Retryable) })
    stub_const("ShovikProbe::Namespace", Module.new)
    stub_const("ShovikProbe::Matcher", Module.new.tap { |mod| mod.define_singleton_method(:===) { |error| error.is_a?(IOError) } })
    stub_const("ShovikProbe::ERRORS", [ShovikProbe::Error, IOError])
    stub_const("ShovikProbe::MIXED", [ShovikProbe::Error, ShovikProbe::Response])
  end

  def violations(source)
    path = File.join(@dir, "probe.rb")
    File.write(path, source)
    described_class.call([path], root: @dir).map(&:to_s)
  end

  it "accepts exception classes, included exception modules and splatted exception lists" do
    expect(violations(<<~RUBY)).to be_empty
      begin
        work
      rescue StandardError, ShovikProbe::Error, ::IOError, ShovikProbe::Retryable, ShovikProbe::Matcher, *ShovikProbe::ERRORS
        nil
      end
      x = work rescue nil
    RUBY
  end

  it "does not crash on dynamic class paths" do
    expect(violations(<<~RUBY)).to eq(["probe.rb:4: rescue ShovikProbe::Namespace is ShovikProbe::Namespace, not an exception class"])
      class self::Inner
        def call
          work
        rescue ShovikProbe::Namespace
          nil
        end
      end
    RUBY
  end

  it "resolves constants through the lexical nesting" do
    expect(violations(<<~RUBY)).to eq(["probe.rb:5: rescue Response is ShovikProbe::Response, not an exception class"])
      module ShovikProbe
        class Client
          def call
            work
          rescue Error, Response
            nil
          end
        end
      end
    RUBY
  end

  it "reports namespaces, undefined constants and non-exceptions in splatted lists" do
    source = <<~RUBY
      begin
        work
      rescue ShovikProbe::Namespace, ShovikProbe::Missing, *ShovikProbe::MIXED
        nil
      end
    RUBY

    expect(violations(source)).to contain_exactly(
      "probe.rb:3: rescue ShovikProbe::Namespace is ShovikProbe::Namespace, not an exception class",
      "probe.rb:3: rescue ShovikProbe::Missing is not defined",
      "probe.rb:3: rescue *ShovikProbe::MIXED contains non-exceptions: ShovikProbe::Response"
    )
  end
end
