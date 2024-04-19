require "spec_helper"
require "grokdown/matching"

RSpec.describe Grokdown::Matching do
  around do |example|
    old_knowns = described_class.class_variable_get(:@@knowns)
    described_class.class_variable_set(:@@knowns, [])
    example.run
    described_class.class_variable_set(:@@knowns, old_knowns)
  end

  it ".matches? with an object no extending class matches" do
    doc, paragraph, link, text = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class).to_not be_matches(doc)
    expect(described_class).to_not be_matches(paragraph)
    expect(described_class).to_not be_matches(link)
    expect(described_class).to_not be_matches(text)
  end

  it ".for with an object no extending class matches" do
    doc, paragraph, link, text = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class.for(doc)).to be_nil
    expect(described_class.for(paragraph)).to be_nil
    expect(described_class.for(link)).to be_nil
    expect(described_class.for(text)).to be_nil
  end

  it ".matches? with an object an extending class matches" do
    described_module = described_class
    Class.new do
      extend described_module
      match { |node| node.type == :link }
    end

    doc, paragraph, link, text = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class).to_not be_matches(doc)
    expect(described_class).to_not be_matches(paragraph)
    expect(described_class).to be_matches(link)
    expect(described_class).to_not be_matches(text)
  end

  it ".for with an object an extending class matches" do
    described_module = described_class

    type = Class.new do
      extend described_module
      match { |node| node.type == :link }
    end

    doc, paragraph, link, text = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class.for(doc)).to be_nil
    expect(described_class.for(paragraph)).to be_nil
    expect(described_class.for(link)).to eq(type)
    expect(described_class.for(text)).to be_nil
  end
end
