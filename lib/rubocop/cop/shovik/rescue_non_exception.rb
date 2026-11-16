# frozen_string_literal: true

module RuboCop
  module Cop
    module Shovik
      # Flags `rescue` of a constant that is known not to be an exception class,
      # such as a library namespace (`Net::SMTP`, `JSON`, `Timeout`) or a core value class.
      # Only constants on the `NonExceptionConstants` list are checked, so custom errors never trigger it.
      #
      # @example
      #   # bad
      #   rescue Timeout
      #   rescue Net::SMTP
      #
      #   # good
      #   rescue Timeout::Error
      #   rescue Net::SMTPError
      class RescueNonException < Base
        MSG = "`%<name>s` is not an exception class; rescue the specific error class instead."

        def on_resbody(node)
          node.exceptions.each do |exception|
            next unless exception.const_type?

            name = exception.const_name
            next unless non_exception_constants.include?(name)

            add_offense(exception, message: format(MSG, name: name))
          end
        end

        private

        def non_exception_constants
          @non_exception_constants ||= Array(cop_config["NonExceptionConstants"]).to_set
        end
      end
    end
  end
end
