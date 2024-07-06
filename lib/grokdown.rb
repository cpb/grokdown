# frozen_string_literal: true

require_relative "grokdown/composing"
require_relative "grokdown/creating"
require_relative "grokdown/matching"
require_relative "grokdown/version"

module Grokdown
  class Error < StandardError; end

  def self.included(base)
    base.extend(Matching)
    base.extend(Creating)
    base.extend(Composing)
  end
end
