# frozen_string_literal: true

module RuboCop
  module Cop
    module Shovik
      # Requires tests that read the clock to pin it first, so they cannot flake at day, month or DST boundaries.
      #
      # A clock read is pinned when it sits inside a pinning call (`travel_to`, `freeze_time`, `travel`,
      # `Timecop.freeze`/`travel`), inside a test or example whose body pins the clock, or inside a group
      # or class whose per-example `setup`/`before`/`around` hook pins it. Group-level pins cover only code that
      # runs per example (examples, `let`/`subject`, per-example hooks, methods), not load-time group bodies or
      # `before(:all)`. Including a module or shared context named in
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
          Time: %i[current now new],
          DateTime: %i[current now]
        }.freeze
        ZONE_METHODS = %i[now today yesterday tomorrow].to_set.freeze
        DURATION_UNITS = %i[second seconds minute minutes hour hours day days week weeks month months year years].to_set.freeze
        RELATIVE_METHODS = %i[ago from_now since until].to_set.freeze
        PIN_METHODS = %i[travel_to freeze_time travel].to_set.freeze
        TIMECOP_METHODS = %i[freeze travel].to_set.freeze
        HOOK_METHODS = %i[setup before around prepend_before append_before].to_set.freeze
        EXAMPLE_METHODS = %i[it specify example scenario its test focus fit fspecify fexample].to_set.freeze
        ALL_HOOK_METHODS = (HOOK_METHODS | %i[teardown after prepend_after append_after]).freeze
        LAZY_METHODS = %i[let let! subject subject!].to_set.freeze
        PER_EXAMPLE_SCOPES = %i[each example].to_set.freeze
        INCLUDE_METHODS = %i[include include_context].to_set.freeze

        def on_send(node)
          return unless clock_read?(node)
          return if pinned?(node)

          add_offense(node, message: format(MSG, source: node.source))
        end
        alias on_csend on_send

        private

        def clock_read?(node)
          return false if node.arguments?

          class_clock_read?(node) || zone_clock_read?(node) || relative_clock_read?(node)
        end

        def class_clock_read?(node)
          CLOCK_CLASS_METHODS.any? { |klass, methods| const?(node.receiver, klass) && methods.include?(node.method_name) }
        end

        def zone_clock_read?(node)
          receiver = node.receiver
          ZONE_METHODS.include?(node.method_name) && receiver&.send_type? && receiver.method?(:zone) &&
            const?(receiver.receiver, :Time)
        end

        def relative_clock_read?(node)
          RELATIVE_METHODS.include?(node.method_name) && node.receiver&.send_type? &&
            DURATION_UNITS.include?(node.receiver.method_name)
        end

        def const?(node, name)
          node&.const_type? && node.const_name.delete_prefix("::") == name.to_s
        end

        def pinned?(node)
          per_example = false
          node.each_ancestor(:block, :numblock, :send, :def, :class).any? do |ancestor|
            next true if pin_call?(ancestor) || pinning_example?(ancestor)

            per_example ||= ancestor.def_type? || per_example_block?(ancestor)
            per_example && pinning_scope?(ancestor)
          end
        end

        def bare_block?(node, methods)
          (node.block_type? || node.numblock_type?) && node.send_node.receiver.nil? && methods.include?(node.method_name)
        end

        def per_example_block?(node)
          bare_block?(node, EXAMPLE_METHODS) || bare_block?(node, LAZY_METHODS) || per_example_hook?(node, ALL_HOOK_METHODS)
        end

        def per_example_hook?(node, methods)
          return false unless bare_block?(node, methods)

          scope = node.send_node.first_argument
          scope.nil? || !scope.sym_type? || PER_EXAMPLE_SCOPES.include?(scope.value)
        end

        def pin_call?(node)
          node = node.send_node if node.block_type? || node.numblock_type?
          node.send_type? && pin_method?(node)
        end

        def pin_method?(node)
          return PIN_METHODS.include?(node.method_name) if node.receiver.nil?

          const?(node.receiver, :Timecop) && TIMECOP_METHODS.include?(node.method_name)
        end

        def pinning_example?(node)
          example = node.def_type? ? node.method_name.start_with?("test_") : bare_block?(node, EXAMPLE_METHODS)
          example && contains_pin?(node.body)
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
          hook = node.def_type? ? node.method?(:setup) : per_example_hook?(node, HOOK_METHODS)
          hook && contains_pin?(node.body)
        end

        def pinning_include?(node)
          return false unless node.send_type? && node.receiver.nil? && INCLUDE_METHODS.include?(node.method_name)

          node.arguments.any? do |argument|
            name = argument.const_type? ? argument.const_name : argument.str_content
            pinning_helpers.include?(name)
          end
        end

        def contains_pin?(node)
          node&.each_node(:send)&.any? { |send| pin_method?(send) }
        end

        def pinning_helpers
          @pinning_helpers ||= Array(cop_config["PinningHelpers"]).to_set
        end
      end
    end
  end
end
