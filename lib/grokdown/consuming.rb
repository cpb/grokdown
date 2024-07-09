require "grokdown"
require "grokdown/composing"

module Grokdown
  module Consuming
    def self.extended(base)
      base.extend(Composing)
      base.send(:include, InstanceMethods)
    end

    def consumes?(node)
      can_compose?(node)
    end

    def consume(inst, node)
      raise ArgumentError, "#{inst.class} cannot consume #{node.class}" unless consumes?(node)

      begin
        inst.add_composable(node)
      rescue ArgumentError => e
        raise ArgumentError, "#{inst.class}##{consuming_method} #{e.message}"
      end
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
