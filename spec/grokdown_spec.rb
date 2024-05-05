# frozen_string_literal: true

require "spec_helper"
require "forwardable"
require "grokdown/matching"
require "grokdown/document"

RSpec.describe Grokdown do
  it "can deserialize README.md to model the license and usage with some structs" do
    described_module = described_class

    stub_const("Text", Class.new(String) do
      include described_module

      def self.matches_node?(node) = node.type == :text

      def self.arguments_from_node(node) = node.string_content
    end)

    stub_const("Link", Struct.new(:href, :title, :text, keyword_init: true) do
      include described_module

      def self.matches_node?(node) = node.type == :link

      def self.arguments_from_node(node) = {href: node.url, title: node.title}

      def self.aggregate_node(inst, node)
        case node
        when Text
          inst.text = node
        end
      end

      def on_text(&block)
        @text_callback = block
      end

      def text=(new_text)
        return if self[:text]

        @text_callback&.call(new_text)

        self[:text] = new_text
      end
    end)

    stub_const("Code", Class.new(String) do
      include described_module

      def self.matches_node?(node) = node.type == :code_block

      def self.arguments_from_node(node) = node.string_content.chomp
    end)

    stub_const("Paragraph", Struct.new(:text, :code, keyword_init: true) {
      include described_module

      def self.matches_node?(node) = node.type == :paragraph

      def self.aggregate_node(inst, node)
        case node
        when Text
          inst.text = node
        when Code
          inst.code = node
        end
      end
    })

    stub_const("License", Struct.new(:paragraph, :href, :name, :link, keyword_init: true) do
      include described_module

      def self.matches_node?(node) = node.type == :header && node.header_level == 2 && node.first_child.string_content == "License"

      def self.aggregate_node(inst, node)
        case node
        when Paragraph
          inst.paragraph = node
        when Link
          inst.link = node
        end
      end

      extend Forwardable

      def_delegator :link, :href

      def_delegator :paragraph, :text

      def link=(link)
        self[:link] = link
        license = self
        link.on_text do |value|
          license.name = value
        end
      end
    end)

    stub_const("Usage", Struct.new(:paragraph, keyword_init: true) do
      include described_module
      extend Forwardable

      def self.matches_node?(node) = node.type == :header && node.header_level == 2 && node.first_child.string_content == "Usage"

      def self.aggregate_node(inst, node)
        case node
        when Paragraph
          inst.paragraph = node
        when Text
          inst.on_header_text(node)
        end
      end

      def on_header_text(text)
      end

      def_delegators :paragraph, :text, :code
    end)

    stub_const("Installation", Struct.new(:alternatives, keyword_init: true) do
      include described_module
      extend Forwardable

      def self.matches_node?(node) = node.type == :header && node.header_level == 2 && node.first_child.string_content == "Installation"

      def self.aggregate_node(inst, node)
        case node
        when Paragraph
          inst.on_alternative(node)
        when Text
          inst.on_header_text(node)
        end
      end

      def on_header_text(text)
      end

      def on_alternative(alternative)
        self.alternatives ||= []
        alternatives.push(alternative)
      end
    end)

    Struct.new(:text, :link, :code, :paragraph, :keyword_init) do
      include described_module

      def self.matches_node?(node) = node.type == :header && node.header_level == 2

      def self.aggregate_node(inst, node)
        case node
        when Text
          inst.text = node
        when Link
          inst.link = node
        when Code
          inst.code = node
        when Paragraph
          inst.paragraph = node
        end
      end
    end

    Struct.new(:license, :usage, :installation, :rest, keyword_init: true) do
      include described_module

      def self.matches_node?(node) = node.type == :document

      def self.aggregate_node(inst, node)
        case node
        when License
          inst.license = node
        when Usage
          inst.usage = node
        when Installation
          inst.installation = node
        when Paragraph
          inst.on_paragraph(node)
        end
      end

      def rest = self[:rest] ||= []

      def on_paragraph(paragraph) = rest.push(paragraph)
    end

    readme = Grokdown::Document.new(Pathname.new(__FILE__).dirname.join("../README.md").read).first

    expect(readme.license)
      .to have_attributes(name: "MIT License")
      .and have_attributes(href: "https://opensource.org/licenses/MIT")
      .and have_attributes(text: "The gem is available as open source under the terms of the ")

    expect(readme.installation.alternatives)
      .to match_array([
        have_attributes(
          text: "Install the gem and add to the application's Gemfile by executing:",
          code: "$ bundle add grokdown"
        ),
        have_attributes(
          text: "If bundler is not being used to manage dependencies, install the gem by executing:",
          code: "$ gem install grokdown"
        )
      ])
    Grokdown::Matching.class_variable_set(:@@knowns, [])

    expect do
      expect(Module.new.module_eval(readme.usage.code, "README.md", 10)).to eq("https://opensource.org/licenses/MIT")
    end.to output("MIT License\n").to_stdout
  end

  it "has a version number" do
    expect(Grokdown::VERSION).not_to be nil
  end
end
