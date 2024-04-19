require "spec_helper"
require "commonmarker"
require "grokdown/creating"

RSpec.describe Grokdown::Creating, "Hash" do
  subject do
    described_module = described_class
    Class.new(Hash) do
      extend described_module
    end
  end

  it ".build initializes from Hash arguments returned by the .create block given a node" do
    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    subject.create { |node| {text: node.first_child.string_content} }

    expect(subject.build(link)).to have_attributes(
      keys: [:text],
      values: ["the node text"],
      node: link
    )
  end
end
