# frozen_string_literal: true

require "prism"

module Shovik
  # Resolves every constant named in a `rescue` clause against the loaded app and reports the ones that
  # are undefined or are not exception classes. Accepted: a class below Exception, a module an exception
  # includes, or a module with its own `===` matcher.
  class RescueClassCheck
    UNDEFINED = Object.new.freeze

    Violation = Data.define(:path, :line, :name, :reason) do
      def to_s = "#{path}:#{line}: rescue #{name} #{reason}"
    end

    class RescueCollector < Prism::Visitor
      attr_reader :rescues

      def initialize
        super
        @nesting = []
        @rescues = []
      end

      def visit_class_node(node) = within(node) { super }
      def visit_module_node(node) = within(node) { super }

      def visit_rescue_node(node)
        @rescues << [@nesting.dup, node]
        super
      end

      private

      def within(node)
        @nesting.push(scope_name(node))
        yield
      ensure
        @nesting.pop
      end

      def scope_name(node)
        name = node.constant_path.full_name
        name.start_with?("::") || @nesting.empty? ? name.delete_prefix("::") : "#{@nesting.last}::#{name}"
      rescue Prism::ConstantPathNode::DynamicPartsInConstantPathError
        "#{@nesting.last}::(dynamic)"
      end
    end

    def self.call(paths, root: Dir.pwd) = new(paths, root:).violations

    def initialize(paths, root:)
      @paths = paths
      @root = root
    end

    def violations
      @paths.flat_map { |path| check_file(path) }
    end

    private

    def check_file(path)
      collector = RescueCollector.new
      Prism.parse_file(path).value.accept(collector)
      relative = Pathname(path).relative_path_from(@root).to_s
      collector.rescues.flat_map { |nesting, node| check_rescue(relative, nesting, node) }
    end

    def check_rescue(path, nesting, node)
      node.exceptions.filter_map { |expression| check(nesting, expression) }.map do |name, reason|
        Violation.new(path, node.location.start_line, name, reason)
      end
    end

    def check(nesting, expression)
      splat = expression.is_a?(Prism::SplatNode)
      expression = expression.expression if splat
      return unless expression.is_a?(Prism::ConstantReadNode) || expression.is_a?(Prism::ConstantPathNode)

      name = expression.full_name
      value = resolve(nesting, name)
      return [name, "is not defined"] if value.equal?(UNDEFINED)

      splat ? check_list("*#{name}", value) : check_value(name, value)
    rescue Prism::ConstantPathNode::DynamicPartsInConstantPathError
      nil
    end

    def check_list(name, value)
      return [name, "is not an Array of exception classes"] unless value.is_a?(Array)

      bad = value.reject { |element| exception_matcher?(element) }
      [name, "contains non-exceptions: #{bad.map { |element| describe(element) }.join(', ')}"] if bad.any?
    end

    def check_value(name, value)
      [name, "is #{describe(value)}, not an exception class"] unless exception_matcher?(value)
    end

    def resolve(nesting, name)
      return constant(Object, name.delete_prefix("::")) if name.start_with?("::")

      head = name.split("::").first
      scopes = nesting.reverse.filter_map { |scope| constant(Object, scope).then { |mod| mod unless mod.equal?(UNDEFINED) } }
      lexical = scopes.find { |scope| scope.const_defined?(head, false) }
      constant(lexical || scopes.first || Object, name)
    end

    def constant(scope, name)
      scope.const_get(name)
    rescue NameError
      UNDEFINED
    end

    def describe(value)
      value.is_a?(Module) && value.name ? value.name : value.inspect
    end

    def exception_matcher?(value)
      return value <= Exception if value.is_a?(Class)
      return false unless value.is_a?(Module)

      value.singleton_class.instance_method(:===).owner != Module || Exception.descendants.any? { |klass| klass.include?(value) }
    end
  end
end
