require "spec_helper"
require "commonmarker"
require "grokdown/creating"

RSpec.describe Grokdown::Creating do
  it ".build initializes from Array arguments returned by the collection_of_arguments_from_node hook method given a node" do
    described_module = described_class

    type = Struct.new(:text) do
      extend described_module
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    def type.collection_of_arguments_from_node(node) = [node.first_child.string_content]

    expect(type.build(link)).to match_array(have_attributes(
      text: "the node text",
      node: link
    ))
  end

  it ".build initializes from Array arguments returned by the arguments_from_node hook method given a node" do
    described_module = described_class

    type = Struct.new(:text) do
      extend described_module

      def self.arguments_from_node(node) = [node.first_child.string_content]
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    expect(type.build(link)).to have_attributes(
      text: "the node text",
      node: link
    )
  end

  it ".build initializes from Hash arguments returned by the arguments_from_node hook method given a node" do
    described_module = described_class

    type = Struct.new(:text, keyword_init: true) do
      extend described_module
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    def type.arguments_from_node(node) = {text: node.first_child.string_content}

    expect(type.build(link)).to have_attributes(
      text: "the node text",
      node: link
    )
  end

  it ".build initializes from #to_array arguments returned by the arguments_from_node hook method given a node" do
    described_module = described_class

    stub_const("ArgumentType", Struct.new(:to_array))

    type = Struct.new(:text) do
      extend described_module
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    def type.arguments_from_node(node) = ArgumentType.new(node.first_child.string_content)

    expect(type.build(link)).to have_attributes(
      text: "the node text",
      node: link
    )
  end
end
