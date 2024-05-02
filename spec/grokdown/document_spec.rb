require "spec_helper"
require "grokdown/document"
require "grokdown/creating"
require "grokdown/consuming"

RSpec.describe Grokdown::Document do
  it "#initialized with a markdown file, creates an iterable, walk-able list of Grokdown::NeverConsumes from the children of the document" do
    doc, paragraph, link, text = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class.new("[text](https://host.com)").each.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), Grokdown::NeverConsumes.new(link), Grokdown::NeverConsumes.new(text)])

    expect(described_class.new("[text](https://host.com)").walk.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), Grokdown::NeverConsumes.new(link), Grokdown::NeverConsumes.new(text)])
  end

  it "with some Classes with Grokdown::Matching.matches_node?, builds matching instances with Grokdown::Matching.create, and reshapes the tree a bit with Growkdown::Consuming.consumes", :aggregate_failures do
    text = Class.new(String) do
      extend Grokdown::Matching
      extend Grokdown::Creating

      def consumes?(*) = false

      def self.matches_node?(node) = node.type == :text

      create { |node| node.string_content }
    end

    link = Struct.new(:href, :title, :text, keyword_init: true) do
      extend Grokdown::Matching
      extend Grokdown::Creating
      extend Grokdown::Consuming

      def self.matches_node?(node) = node.type == :link

      create { |node| {href: node.url, title: node.title} }
      consumes text => :text=
    end

    doc, paragraph, *_rest = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class.new("[text](https://host.com)").each.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), link.new(href: "https://host.com", title: "", text: "text")])
    expect(described_class.new("[text](https://host.com)").walk.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), link.new(href: "https://host.com", title: "", text: "text"), "text"])
  end
end
