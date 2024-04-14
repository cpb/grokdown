require "grokdown"

module Grokdown
  module Consuming
    def self.extended(base)
      base.send(:include, InstanceMethods)
    end

    def consumes?(node)
      @consumables ||= {}
      @consumables.has_key?(node.class)
    end

    def consumes(mapping = {})
      @consumables = mapping
    end

    def consume(inst, node)
      @consumables ||= {}
      inst.send(@consumables.fetch(node.class), node)
    rescue KeyError
      raise ArgumentError, "#{inst.class} cannot consume #{node.class}"
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
