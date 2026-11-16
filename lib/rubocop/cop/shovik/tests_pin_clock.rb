# frozen_string_literal: true

module RuboCop
  module Cop
    module Shovik
      # Requires tests that read the clock to pin it first, so they cannot flake at day, month or DST boundaries.
      #
      # A clock read is pinned when it sits inside a pinning call (`travel_to`, `freeze_time`, `travel`,
      # `Timecop.freeze`/`travel`), inside a test or example whose body pins the clock, or inside a group
      # or class whose `setup`/`before`/`around` hook pins it. Including a module or shared context named in
      # `PinningHelpers` also counts as pinning for that group.
      #
      # @example
      #   # bad
      #   it "shows this month" do
      #     expect(page).to have_content(Date.current.strftime("%B"))
      #   end
      #
      #   # good
      #   before { travel_to Time.zone.local(2026, 11, 15, 12) }
      #   it "shows this month" do
      #     expect(page).to have_content(Date.current.strftime("%B"))
      #   end
      class TestsPinClock < Base
        MSG = "Pin the clock (`travel_to`/`freeze_time` in the test or its setup) before calling `%<source>s`."

        CLOCK_CLASS_METHODS = {
          Date: %i[current today yesterday tomorrow],
          Time: %i[current now],
          DateTime: %i[current now]
        }.freeze
        ZONE_METHODS = %i[now today yesterday tomorrow].to_set.freeze
        DURATION_UNITS = %i[second seconds minute minutes hour hours day days week weeks month months year years].to_set.freeze
        RELATIVE_METHODS = %i[ago from_now since until].to_set.freeze
        PIN_METHODS = %i[travel_to freeze_time travel].to_set.freeze
        TIMECOP_METHODS = %i[freeze travel].to_set.freeze
        HOOK_METHODS = %i[setup before around prepend_before append_before].to_set.freeze
        EXAMPLE_METHODS = %i[it specify example scenario its test focus fit fspecify fexample].to_set.freeze
        INCLUDE_METHODS = %i[include include_context].to_set.freeze

        def on_send(node)
          return unless clock_read?(node)
          return if pinned?(node)

          add_offense(node, message: format(MSG, source: node.source))
        end
        alias on_csend on_send

        private

        def clock_read?(node)
          class_clock_read?(node) || zone_clock_read?(node) || relative_clock_read?(node)
        end

        def class_clock_read?(node)
          receiver = node.receiver
          return false unless receiver&.const_type?

          CLOCK_CLASS_METHODS.fetch(receiver.const_name.delete_prefix("::").to_sym, []).include?(node.method_name)
        end

        def zone_clock_read?(node)
          receiver = node.receiver
          return false unless ZONE_METHODS.include?(node.method_name)
          return false unless receiver&.send_type? && receiver.method?(:zone) && receiver.receiver&.const_type?

          receiver.receiver.const_name.delete_prefix("::") == "Time"
        end

        def relative_clock_read?(node)
          RELATIVE_METHODS.include?(node.method_name) && !node.arguments? && node.receiver&.send_type? &&
            duration_unit?(node.receiver)
        end

        def duration_unit?(node)
          DURATION_UNITS.include?(node.method_name)
        end

        def pinned?(node)
          node.each_ancestor(:block, :numblock, :send, :def, :class).any? do |ancestor|
            pin_call?(ancestor) || pinning_block?(ancestor) || pinning_scope?(ancestor)
          end
        end

        def pin_call?(node)
          return pin_method?(node) if node.send_type?

          (node.block_type? || node.numblock_type?) && pin_method?(node.send_node)
        end

        def pin_method?(node)
          return PIN_METHODS.include?(node.method_name) if node.receiver.nil?

          node.receiver.const_type? && node.receiver.const_name == "Timecop" && TIMECOP_METHODS.include?(node.method_name)
        end

        def pinning_block?(node)
          return false unless node.block_type? || node.numblock_type? || node.def_type?

          example_or_test?(node) && contains_pin?(node.body)
        end

        def example_or_test?(node)
          return node.method_name.to_s.start_with?("test_") if node.def_type?

          node.send_node.receiver.nil? && EXAMPLE_METHODS.include?(node.method_name)
        end

        def pinning_scope?(node)
          return false unless node.block_type? || node.class_type?

          scope_children(node).any? { |child| pinning_hook?(child) || pinning_include?(child) }
        end

        def scope_children(node)
          body = node.body
          return [] unless body

          body.begin_type? ? body.children : [body]
        end

        def pinning_hook?(node)
          if node.def_type?
            node.method?(:setup) && contains_pin?(node.body)
          elsif node.block_type? || node.numblock_type?
            node.send_node.receiver.nil? && HOOK_METHODS.include?(node.method_name) && contains_pin?(node.body)
          else
            false
          end
        end

        def pinning_include?(node)
          return false unless node.send_type? && node.receiver.nil? && INCLUDE_METHODS.include?(node.method_name)

          node.arguments.any? { |argument| pinning_helpers.include?(helper_name(argument)) }
        end

        def helper_name(argument)
          if argument.const_type?
            argument.const_name
          elsif argument.str_type?
            argument.value
          end
        end

        def contains_pin?(node)
          return false unless node

          node.each_node(:send).any? { |send| pin_method?(send) }
        end

        def pinning_helpers
          @pinning_helpers ||= Array(cop_config["PinningHelpers"]).to_set
        end
      end
    end
  end
end
