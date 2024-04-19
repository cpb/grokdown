# frozen_string_literal: true

require "spec_helper"
require "forwardable"
require "grokdown/matching"
require "grokdown/document"

RSpec.describe Grokdown do
  it "can deserialize README.md to model the license and usage with some structs" do
    described_module = described_class

    text = Class.new(String) do
      include described_module

      def consumes?(*) = false

      match { |node| node.type == :text }
      create { |node| node.string_content }
    end

    link = Struct.new(:href, :title, :text, keyword_init: true) do
      include described_module

      match { |node| node.type == :link }
      create { |node| {href: node.url, title: node.title} }
      consumes text => :text=

      def on_text(&block)
        @text_callback = block
      end

      def text=(new_text)
        return if self[:text]

        @text_callback&.call(new_text)

        self[:text] = new_text
      end
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
        link.on_text do |value|
          license.name = value
        end
      end
    end

    code = Class.new(String) do
      include described_module

      match { |node| node.type == :code_block && node.fence_info == "ruby" }
      create { |node| node.string_content }
    end

    usage = Struct.new(:text, :code, keyword_init: true) do
      include described_module

      match { |node| node.type == :header && node.header_level == 2 && node.first_child.string_content == "Usage" }
      consumes text => :text=, code => :code=
    end

    Struct.new(:text, :link, :code, :keyword_init) do
      include described_module

      match { |node| node.type == :header && node.header_level == 2 }
      consumes text => :text=, link => :link=, code => :code=
    end

    Struct.new(:license, :usage, keyword_init: true) do
      include described_module

      match { |node| node.type == :document }

      consumes license => :license=, usage => :usage=
    end

    readme = Grokdown::Document.new(Pathname.new(__FILE__).dirname.join("../README.md").read).first

    expect(readme.license)
      .to have_attributes(name: "MIT License")
      .and have_attributes(href: "https://opensource.org/licenses/MIT")
      .and have_attributes(text: "The gem is available as open source under the terms of the ")

    Grokdown::Matching.class_variable_set(:@@knowns, [])

    expect do
      expect(Module.new.module_eval(readme.usage.code, "README.md", 10)).to eq("https://opensource.org/licenses/MIT")
    end.to output("MIT License\n").to_stdout
  end

  it "has a version number" do
    expect(Grokdown::VERSION).not_to be nil
  end
end
