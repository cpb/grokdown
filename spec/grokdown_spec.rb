# frozen_string_literal: true

require "spec_helper"
require "forwardable"
require "grokdown/matching"
require "grokdown/document"

RSpec.describe Grokdown, type: :aruba do
  it "can deserialize README.md to model the license and usage with some structs" do
    described_module = described_class

    stub_const("Text", Class.new(String) do
      include described_module

      def self.matches_node?(node) = node.type == :text

      def self.arguments_from_node(node) = node.string_content
    end)

    stub_const("Link", Struct.new(:href, :title, :text, :parent, keyword_init: true) do
      include described_module

      def self.matches_node?(node) = node.type == :link

      def self.arguments_from_node(node) = {href: node.url, title: node.title}

      def add_text(node)
        return if text

        self.text = node

        parent.add_composable(node) if parent&.can_compose?(node)
      end
    end)

    stub_const("Code", Class.new(String) do
      include described_module

      def self.matches_node?(node) = node.type == :code_block

      def self.arguments_from_node(node) = node.string_content.chomp
    end)

    stub_const("Literal", Class.new(String) do
      include described_module

      def self.matches_node?(node) = node.type == :code

      def self.arguments_from_node(node) = node.string_content.chomp
    end)

    stub_const("Paragraph", Struct.new(:text, :code, :parent, keyword_init: true) {
      include described_module

      def self.matches_node?(node) = node.type == :paragraph

      def append_text(node)
        text&.<<(node) || self.text = node.to_s
      end

      def add_text(node) = append_text(node)

      def add_literal(node) = append_text(node)

      def add_code(node)
        self.code = node

        parent.add_composable(node) if parent&.can_compose?(node)
      end
    })

    stub_const("License", Struct.new(:paragraph, :href, :name, :link, keyword_init: true) do
      include described_module

      def self.matches_node?(node) = node.type == :header && node.header_level == 2 && node.first_child.string_content == "License"

      def add_paragraph(node) = self.paragraph = node

      def add_link(node)
        node.parent = self
        self.link = node
      end

      def add_text(node) = self.name = node

      extend Forwardable

      def_delegator :link, :href

      def_delegator :paragraph, :text
    end)

    stub_const("Usage", Struct.new(:paragraph, :examples, keyword_init: true) do
      include described_module
      extend Forwardable

      def self.matches_node?(node) = node.type == :header && node.header_level == 2 && node.first_child.string_content == "Usage"

      def add_paragraph(node) = self.paragraph = node

      def add_usage_example(node)
        self.examples ||= []
        self.examples.push node
      end

      def add_text(node)
      end

      def_delegators :paragraph, :text, :code
    end)

    stub_const("UsageExample", Struct.new(:name, :instructions, :files, :shell_command, keyword_init: true) do
      include described_module

      def self.matches_node?(node) = node.type == :header && node.header_level == 3

      def add_text(node) = self.name = node

      def add_example_file(node)
        self.files ||= []
        self.files.push node
      end

      def add_code(node) = self.shell_command = node

      def add_paragraph(node)
        node.parent = self
        self.instructions = node.node.to_commonmark
      end

      def can_compose?(node)
        return false if shell_command && node.is_a?(Code)

        super
      end
    end)

    stub_const("ExampleFile", Struct.new(:name, :contents, keyword_init: true) do
      include described_module

      def self.matches_node?(node) = node.type == :header && node.header_level == 5

      def add_literal(node) = self.name = node

      def add_code(node) = self.contents = node

      def can_compose?(node)
        return false if contents && node.is_a?(Code)

        super
      end
    end)

    stub_const("Installation", Struct.new(:alternatives, keyword_init: true) do
      include described_module
      extend Forwardable

      def self.matches_node?(node) = node.type == :header && node.header_level == 2 && node.first_child.string_content == "Installation"

      def add_paragraph(node)
        self.alternatives ||= []
        alternatives.push(node)
      end

      def add_text(node)
      end
    end)

    Struct.new(:text, :link, :code, :paragraph, :keyword_init) do
      include described_module

      def self.matches_node?(node) = node.type == :header && node.header_level == 2

      def add_link(node) = self.link = node

      def add_text(node) = self.text = node

      def add_code(node) = (self.code = node)

      def add_paragraph(node) = self.paragraph = node
    end

    Struct.new(:license, :usage, :installation, :rest, keyword_init: true) do
      include described_module

      def self.matches_node?(node) = node.type == :document

      def add_license(node) = self.license = node

      def add_usage(node) = self.usage = node

      def add_installation(node) = self.installation = node

      def add_paragraph(node) = rest.push(node)

      def rest = self[:rest] ||= []
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

    readme.usage.examples.each do |example|
      example.files.each do |file|
        write_file file.name, file.contents
      end

      run_command(example.shell_command)
      expect(last_command_started).to have_output "MIT License"
    end

  rescue Exception => e
    puts e
    raise e
  else
    @skip_pry = true
  ensure
    binding.irb unless @skip_pry
  end

  it "has a version number" do
    expect(Grokdown::VERSION).not_to be nil
  end
end
