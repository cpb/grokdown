module Grokdown
  class NeverConsumes < BasicObject
    def initialize(node)
      @node = node
    end

    def consumes?(*)
      false
    end

    def respond_to_missing?(name)
      @node.respond_to?(name)
    end

    def method_missing(name, ...)
      @node.send(name, ...)
    end

    attr_reader :node
  end
end
