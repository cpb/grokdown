require "grokdown"

module Grokdown
  module Creating
    def self.extended(base)
      base.send(:include, InstanceMethods)
    end

    def create(many: false, &block)
      @create = block
      @create_many = many
    end

    def build(node)
      if @create
        args = begin
          @create.call(node)
        rescue NoMethodError => e
          raise Error, "cannot find #{e.name} from #{node.to_commonmark.inspect} at #{node.sourcepos[:start_line]} in #{self} create block"
        rescue CommonMarker::NodeError
          raise Error, "could not get string content from #{node.to_commonmark.inspect} at #{node.sourcepos[:start_line]} in #{self} create block"
        end

        _build(args) { |i| i.node = node }
      else
        new.tap { |i| i.node = node }
      end
    end

    private def _build(args, recurse = true, &block)
      case args
      when Hash
        if self < Hash
          new.merge!(args).tap(&block)

        else
          new(**args).tap(&block)

        end
      when Array
        if @create_many && recurse
          args.map { |i| _build(i, false, &block) }
        elsif self < Array
          new(args).tap(&block)

        else
          new(*args).tap(&block)

        end
      else
        new(*args).tap(&block)
      end
    end

    module InstanceMethods
      def sourcepos
        @node&.sourcepos || {}
      end

      def node=(node)
        @node = node
      end

      def node
        @node
      end
    end
  end
end
