require "grokdown"
require "grokdown/composing"

module Grokdown
  module Consuming
    def self.extended(base)
      base.extend(Composing)
      base.send(:include, InstanceMethods)
    end

    class ConsumesChecker < BasicObject
      def initialize
        @aggregated = false
        super
      end

      def aggregated? = @aggregated

      def respond_to_missing?(*) = true

      def method_missing(method, node, ...)
        @aggregated = true
      end
    end

    def consumes?(node)
      can_compose?(node)

      if respond_to?(:aggregate_node)
        inst = ConsumesChecker.new
        aggregate_node(inst, node)
        inst.aggregated?
      end
    end

    def consume(inst, node)
      raise ArgumentError, "#{inst.class} cannot consume #{node.class}" unless consumes?(node)

      begin
        return aggregate_node(inst, node) if respond_to?(:aggregate_node)
      rescue ArgumentError => e
        raise ArgumentError, "#{inst.class}##{consuming_method} #{e.message}"
      end
    rescue NoMethodError => e
      raise NoMethodError, "#{node.class} cannot be passed as argument to #{e.message}"
    end

    module InstanceMethods
      def consumes?(node)
        self.class.consumes?(node)
      end

      def consume(node)
        self.class.consume(self, node)
      end
    end
  end
end
