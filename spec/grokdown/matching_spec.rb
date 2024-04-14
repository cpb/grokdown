require "spec_helper"
require_relative "../../lib/grokdown/matching"

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

  it ".for with an object no extending class matches"

  it ".matches? with an object an extending class matches"
  it ".for with an object an extending class matches"
end
