require "grokdown"

module Grokdown
  module Creating
    def self.extended(base)
      base.send(:include, InstanceMethods)
    end

    def build(node)
      begin
        return collection_of_arguments_from_node(node).map { |args| _build(args, false) { |i| i.node = node } } if respond_to?(:collection_of_arguments_from_node)
      rescue NoMethodError => e
        raise Error, "cannot find #{e.name} from #{node.to_commonmark.inspect} at #{node.sourcepos[:start_line]} in #{self} collection_of_arguments_from_node"
      rescue CommonMarker::NodeError
        raise Error, "could not get string content from #{node.to_commonmark.inspect} at #{node.sourcepos[:start_line]} in #{self} collection_of_arguments_from_node"
      end

      begin
        return _build(arguments_from_node(node)) { |i| i.node = node } if respond_to?(:arguments_from_node)
      rescue NoMethodError => e
        raise Error, "cannot find #{e.name} from #{node.to_commonmark.inspect} at #{node.sourcepos[:start_line]} in #{self} arguments_from_node"
      rescue CommonMarker::NodeError
        raise Error, "could not get string content from #{node.to_commonmark.inspect} at #{node.sourcepos[:start_line]} in #{self} arguments_from_node"
      end

      new.tap { |i| i.node = node }
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
        if self < Array
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
