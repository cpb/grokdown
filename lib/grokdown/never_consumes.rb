require "delegate"

module Grokdown
  class NeverConsumes < SimpleDelegator
    def consumes?(*) = false

    def ==(other)
      to_commonmark == other.to_commonmark
    end

    alias_method :node, :__getobj__
  end
end
