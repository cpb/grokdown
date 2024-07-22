require "delegate"

module Grokdown
  class NeverComposes < SimpleDelegator
    def can_compose?(*) = false

    def ==(other)
      to_commonmark == other.to_commonmark
    end

    alias_method :node, :__getobj__
  end
end
