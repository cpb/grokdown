require "delegate"

module Grokdown
  class NeverConsumes < SimpleDelegator
    def consumes?(*) = false

    alias_method :node, :__getobj__
  end
end
