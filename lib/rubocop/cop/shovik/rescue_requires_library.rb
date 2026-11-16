# frozen_string_literal: true

module RuboCop
  module Cop
    module Shovik
      # Flags `rescue` (and `rescue_from`) of a stdlib error constant in a file that does not
      # require the library defining it, which raises NameError at the moment the rescue is evaluated.
      # Only constant prefixes listed in `Libraries` are checked; the longest matching prefix wins.
      #
      # @example
      #   # bad
      #   rescue Net::SMTPAuthenticationError
      #
      #   # good
      #   require "net/smtp"
      #   rescue Net::SMTPAuthenticationError
      class RescueRequiresLibrary < Base
        MSG = "`%<name>s` needs `require \"%<library>s\"` in this file."

        def_node_matcher :rescue_from_exceptions, "(send nil? :rescue_from $...)"
        def_node_search :required_paths, "(send nil? :require (str $_))"

        def on_new_investigation
          @required = processed_source.ast ? required_paths(processed_source.ast).to_set : Set.new
        end

        def on_resbody(node)
          node.exceptions.each { |exception| check(exception) }
        end

        def on_send(node)
          rescue_from_exceptions(node) { |args| args.each { |arg| check(arg) } }
        end

        private

        def check(node)
          return unless node.const_type?

          name = node.const_name
          prefix = matching_prefix(name)
          return unless prefix

          accepted = Array(libraries[prefix])
          return if accepted.any? { |library| @required.include?(library) }

          add_offense(node, message: format(MSG, name: name, library: accepted.first))
        end

        def matching_prefix(name)
          libraries.keys.select { |prefix| name == prefix || name.start_with?(prefix) }.max_by(&:length)
        end

        def libraries
          cop_config["Libraries"] || {}
        end
      end
    end
  end
end
