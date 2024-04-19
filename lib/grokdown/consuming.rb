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

      consuming_method = @consumables.fetch(node.class) {
        raise ArgumentError, "#{inst.class} cannot consume #{node.class}"
      }

      inst.send(consuming_method, node)
    rescue ArgumentError => e
      raise ArgumentError, "#{inst.class}##{consuming_method} #{e.message}"
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
