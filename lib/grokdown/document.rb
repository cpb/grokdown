require "commonmarker"
require "grokdown"
require "grokdown/matching"
require "grokdown/never_composes"

module Grokdown
  class Document
    def initialize(markdown, options: %i[DEFAULT], extensions: %i[table tasklist strikethrough autolink])
      @walk = []
      @nodes = []

      CommonMarker.render_doc(markdown, options, extensions).walk.reduce(self) do |doc, node|
        decorated_node = case node
        when Matching
          Matching.for(node).build(node)
        else
          NeverComposes.new(node)
        end

        doc.push decorated_node
      end
    end

    def push(node)
      case node
      when Matching
        _push(node)
      when Array
        node.each do |n|
          _push(n)
        end
      else
        _push(node)
      end

      self
    end

    private def _push(node)
      if (accepts = @walk.reverse.find { |i| i.can_compose?(node) })
        accepts.add_composable(node)
      else
        @nodes.push(node)
      end

      @walk.push(node)
    end

    attr_reader :nodes

    include Enumerable
    def each(&block)
      @nodes.each(&block)
    end

    def walk(&block)
      @walk.each(&block)
    end
  end
end
