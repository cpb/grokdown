require "commonmarker/node"
require "grokdown"

module Grokdown
  module Matching
    class << self
      @@knowns = []

      def extended(base)
        @@knowns.push(base)
      end

      def matches?(node)
        @@knowns.any? { |i| i.matches?(node) }
      end

      def for(node)
        @@knowns.find { |i| i.matches?(node) }
      end

      alias_method :===, :matches?
    end

    def match(&block)
      define_singleton_method(:matches_node?, &block)
    end

    def matches?(node)
      node.is_a?(self) || (node.is_a?(CommonMarker::Node) && matches_node?(node))
    end

    alias_method :===, :matches?
  end
end
