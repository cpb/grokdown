require "spec_helper"
require "commonmarker"
require "grokdown/consuming"

RSpec.describe Grokdown::Consuming do
  it "#consume? returns true if Grokdown::Consuming.aggregate_node passed node-instance of a class mapped by .aggregrate_node is true" do
    described_module = described_class

    type = Class.new do
      extend described_module

      def self.aggregate_node(inst, node)
        case node
        when CommonMarker::Node
          inst.gimme(node)
        end
      end
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    expect(type.new).to be_consumes(link)
  end

  it "#consume? a node with class not mapped by .aggregrate_node is false" do
    described_module = described_class

    type = Class.new do
      extend described_module

      def self.aggregate_node(inst, node)
        case node
        when CommonMarker::Node
          inst.gimme(node)
        end
      end
    end

    expect(type.new).not_to be_consumes(Class.new.new)
  end

  it "#consume calls the method mapped by the class of the argument node, with the node" do
    described_module = described_class

    type = Class.new do
      extend described_module

      def self.aggregate_node(inst, node)
        case node
        when CommonMarker::Node
          inst.gimme(node)
        end
      end

      def gimme(node) = node
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    consumer = type.new

    allow(consumer).to receive(:gimme).with(link).and_call_original

    expect(consumer.consume(link)).to eq(link)

    expect(consumer).to have_received(:gimme).with(link)
  end

  it "#consume raises an ArgumentError when given a node with a class not mapped in consumes" do
    described_module = described_class

    type = Class.new do
      extend described_module

      def self.aggregate_node(inst, node)
        case node
        when CommonMarker::Node
          inst.gimme(node)
        end
      end
    end

    consumer = type.new

    expect { consumer.consume(Class.new.new) }.to raise_error(ArgumentError, /cannot consume/)
  end

  it "#consume raises an NoMethodError when given a node with a class mapped to a method that isn't implemented" do
    described_module = described_class

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    type = Class.new do
      extend described_module

      def self.aggregate_node(inst, node)
        case node
        when CommonMarker::Node
          inst.gimme(node)
        end
      end
    end

    consumer = type.new

    expect { consumer.consume(link) }.to raise_error(NoMethodError, /gimme/)
  end
end
