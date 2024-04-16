require "spec_helper"
require "commonmarker"
require_relative "../../../lib/grokdown/creating"

RSpec.describe Grokdown::Creating, "Array" do
  subject do
    described_module = described_class
    Class.new(Array) do
      extend described_module
    end
  end

  it ".build initializes from Array arguments returned by the .create block given a node" do
    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    subject.create { |node| [node.first_child.string_content] }

    expect(subject.build(link))
      .to eq(["the node text"])
      .and have_attributes(
        node: link
      )
  end
end
