require "spec_helper"
require "grokdown/document"
require "grokdown/creating"
require "grokdown/composing"

RSpec.describe Grokdown::Document do
  it "#initialized with a markdown file, creates an iterable, walk-able list of Grokdown::NeverConsumes from the children of the document" do
    doc, paragraph, link, text = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class.new("[text](https://host.com)").each.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), Grokdown::NeverConsumes.new(link), Grokdown::NeverConsumes.new(text)])

    expect(described_class.new("[text](https://host.com)").walk.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), Grokdown::NeverConsumes.new(link), Grokdown::NeverConsumes.new(text)])
  end

  it "with some Classes with Grokdown::Matching.matches_node?, builds matching instances with Grokdown::Matching.arguments_from_node, and composes aggregated root entities Grokdown::Composing conventional composition methods", :aggregate_failures do
    stub_const("Text", Class.new(String) do
      extend Grokdown::Matching
      extend Grokdown::Creating
      extend Grokdown::Composing

      def self.matches_node?(node) = node.type == :text

      def self.arguments_from_node(node) = node.string_content
    end)

    stub_const("Link", Struct.new(:href, :title, :text, keyword_init: true) do
      extend Grokdown::Matching
      extend Grokdown::Creating
      extend Grokdown::Composing

      def self.matches_node?(node) = node.type == :link

      def self.arguments_from_node(node) = {href: node.url, title: node.title}

      def add_text(node) = self.text = node
    end)

    doc, paragraph, *_rest = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class.new("[text](https://host.com)").each.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), Link.new(href: "https://host.com", title: "", text: "text")])
    expect(described_class.new("[text](https://host.com)").walk.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), Link.new(href: "https://host.com", title: "", text: "text"), "text"])
  end
end
