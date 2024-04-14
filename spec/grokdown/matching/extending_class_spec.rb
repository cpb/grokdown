require "spec_helper"
require "commonmarker"
require_relative "../../../lib/grokdown/matching"

RSpec.describe Grokdown::Matching, "extending Class" do
  around do |example|
    old_knowns = described_class.class_variable_get(:@@knowns)
    described_class.class_variable_set(:@@knowns, [])
    example.run
    described_class.class_variable_set(:@@knowns, old_knowns)
  end

  subject do
    described_module = described_class
    Class.new do
      extend described_module
    end
  end

  it ".matches? to an instance" do
    expect(subject).to be_matches(subject.new)
  end

  it ".matches? to a CommonMarker::Node instance using the block passed to .match" do
    subject.match { |node| node.type == :link }

    doc, paragraph, link, text = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(subject).to be_matches(link)
    expect(subject).to_not be_matches(text)
    expect(subject).to_not be_matches(paragraph)
    expect(subject).to_not be_matches(doc)
  end
end
