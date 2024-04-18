# frozen_string_literal: true

require_relative "grokdown/version"
require_relative "grokdown/creating"
require_relative "grokdown/consuming"

module Grokdown
  class Error < StandardError; end

  def self.included(base)
    base.extend(Matching)
    base.extend(Creating)
    base.extend(Consuming)
  end
end
