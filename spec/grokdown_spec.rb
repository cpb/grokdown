# frozen_string_literal: true

require "spec_helper"
require "forwardable"
require "grokdown/matching"
require "grokdown/document"

RSpec.describe Grokdown do
  around do |example|
    old_knowns = Grokdown::Matching.class_variable_get(:@@knowns)
    Grokdown::Matching.class_variable_set(:@@knowns, [])
    example.run
    Grokdown::Matching.class_variable_set(:@@knowns, old_knowns)
  end

  it "can deserialize README.md to model the license with some structs" do
    described_module = described_class

    text = Class.new(String) do
      include described_module

      def consumes?(*) = false

      match { |node| node.type == :text }
      create { |node| node.string_content }
    end

    link = Struct.new(:href, :title, :text, :parent, keyword_init: true) do
      include described_module

      match { |node| node.type == :link }
      create { |node| {href: node.url, title: node.title} }
      consumes text => :text=

      def on(*, &block)
        @text_callback = block
      end

      def text=(new_text)
        return if self[:text]

        @text_callback&.call(new_text)

        self[:text] = new_text
      end
    end

    other_headers = Struct.new(:text, :link, :keyword_init) do
      include described_module

      match { |node| node.type == :header && node.header_level == 2 && node.first_child.string_content != "License" }
      consumes text => :text=, link => :link=
    end

    license = Struct.new(:text, :href, :name, :link, keyword_init: true) do
      include described_module

      match { |node| node.type == :header && node.header_level == 2 && node.first_child.string_content == "License" }
      consumes text => :text=, link => :link=

      extend Forwardable

      def_delegator :link, :href

      def link=(link)
        self[:link] = link
        license = self
        link.on(:text) do |value|
          license.name = value
        end
      end
    end

    Struct.new(:license, :leg, keyword_init: true) do
      include described_module

      match { |node| node.type == :document }

      consumes license => :license=, other_headers => :leg=
    end

    expect(Grokdown::Document.new(Pathname.new(__FILE__).dirname.join("../README.md").read).first.license)
      .to have_attributes(name: "MIT License")
      .and have_attributes(href: "https://opensource.org/licenses/MIT")
      .and have_attributes(text: "The gem is available as open source under the terms of the ")
  end

  it "has a version number" do
    expect(Grokdown::VERSION).not_to be nil
  end
end
