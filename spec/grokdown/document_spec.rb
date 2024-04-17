require "spec_helper"
require_relative "../../lib/grokdown/document"
require_relative "../../lib/grokdown/creating"
require_relative "../../lib/grokdown/consuming"

RSpec.describe Grokdown::Document do
  around do |example|
    old_knowns = Grokdown::Matching.class_variable_get(:@@knowns)
    Grokdown::Matching.class_variable_set(:@@knowns, [])
    example.run
    Grokdown::Matching.class_variable_set(:@@knowns, old_knowns)
  end

  it "#initialized with a markdown file, creates an iterable, walk-able list of Grokdown::NeverConsumes from the children of the document" do
    doc, paragraph, link, text = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class.new("[text](https://host.com)").each.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), Grokdown::NeverConsumes.new(link), Grokdown::NeverConsumes.new(text)])

    expect(described_class.new("[text](https://host.com)").walk.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), Grokdown::NeverConsumes.new(link), Grokdown::NeverConsumes.new(text)])
  end

  it "with some Classes with Grokdown::Matching.match, builds matching instances with Grokdown::Matching.create, and reshapes the tree a bit with Growkdown::Consuming.consumes", :aggregate_failures do
    text = Class.new(String) do
      extend Grokdown::Matching
      extend Grokdown::Creating

      def consumes?(*) = false

      match { |node| node.type == :text }
      create { |node| node.string_content }
    end

    link = Struct.new(:href, :title, :text, keyword_init: true) do
      extend Grokdown::Matching
      extend Grokdown::Creating
      extend Grokdown::Consuming

      match { |node| node.type == :link }
      create { |node| {href: node.url, title: node.title} }
      consumes text => :text=
    end

    doc, paragraph, *_rest = *CommonMarker.render_doc("[text](https://host.com)").walk

    expect(described_class.new("[text](https://host.com)").each.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), link.new(href: "https://host.com", title: "", text: "text")])
    expect(described_class.new("[text](https://host.com)").walk.to_a).to eq([Grokdown::NeverConsumes.new(doc), Grokdown::NeverConsumes.new(paragraph), link.new(href: "https://host.com", title: "", text: "text"), "text"])
  end
end
