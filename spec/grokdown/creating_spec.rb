require "spec_helper"
require "commonmarker"
require_relative "../../lib/grokdown/creating"

RSpec.describe Grokdown::Creating do
  it ".build initializes from Array arguments returned by the .create many: true block given a node" do
    described_module = described_class

    type = Struct.new(:text) do
      extend described_module
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    type.create(many: true) { |node| [node.first_child.string_content] }

    expect(type.build(link)).to match_array(have_attributes(
      text: "the node text",
      node: link
    ))
  end

  it ".build initializes from Array arguments returned by the .create block given a node" do
    described_module = described_class

    type = Struct.new(:text) do
      extend described_module
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    type.create { |node| [node.first_child.string_content] }

    expect(type.build(link)).to have_attributes(
      text: "the node text",
      node: link
    )
  end

  it ".build initializes from Hash arguments returned by the .create block given a node" do
    described_module = described_class

    type = Struct.new(:text, keyword_init: true) do
      extend described_module
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    type.create { |node| {text: node.first_child.string_content} }

    expect(type.build(link)).to have_attributes(
      text: "the node text",
      node: link
    )
  end

  it ".build initializes from #to_array arguments returned by the .create block given a node" do
    described_module = described_class

    argument = Struct.new(:to_array)

    type = Struct.new(:text) do
      extend described_module
    end

    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    type.create { |node| argument.new(node.first_child.string_content) }

    expect(type.build(link)).to have_attributes(
      text: "the node text",
      node: link
    )
  end
end
