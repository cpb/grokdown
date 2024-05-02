require "spec_helper"
require "commonmarker"
require "grokdown/creating"

RSpec.describe Grokdown::Creating, "Array" do
  subject do
    described_module = described_class
    Class.new(Array) do
      extend described_module
    end
  end

  it ".build initializes from Array arguments returned by the .arguments_from_node hook method given a node" do
    _doc, _paragraph, link, _text = *CommonMarker.render_doc("[the node text](https://host.com)").walk

    def subject.arguments_from_node(node) = [node.first_child.string_content]

    expect(subject.build(link))
      .to eq(["the node text"])
      .and have_attributes(
        node: link
      )
  end
end
