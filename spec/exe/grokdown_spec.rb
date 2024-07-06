require "spec_helper"

RSpec.describe "grokdown", type: :aruba do
  before do
    write_file ".grokdown", <<~README
      require "grokdown"

      class Text < String
        include Grokdown

        def self.matches_node?(node) = node.type == :text

        def self.arguments_from_node(node) = node.string_content
      end

      class Link < Struct.new(:href, :title, :text, keyword_init: true)
        include Grokdown

        def self.matches_node?(node) = node.type == :link

        def self.arguments_from_node(node) = {href: node.url, title: node.title}

        def self.aggregate_node(inst, node)
          case node
          when Text
            inst.text = node
          end
        end

        def on_text( &block)
          @text_callback = block
        end

        def text=(new_text)
          return if self[:text]

          @text_callback&.call(new_text)

          self[:text] = new_text
        end
      end

      class License < Struct.new(:text, :href, :name, :link, keyword_init: true)
        include Grokdown

        def self.matches_node?(node) = node.type == :header && node.header_level == 2 && node.first_child.string_content == "License"

        def self.aggregate_node(inst, node)
          case node
          when Text
            inst.text = node
          when Link
            inst.link = node
          end
        end

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

      Struct.new(:text, :link, :keyword_init) do
        include described_module

        def self.matches_node?(node) = node.type == :header && node.header_level == 2

        def self.aggregate_node(inst, node)
          case node
          when Text
            inst.text = node
          when Link
            inst.link = node
          end
        end
      end

      class Readme < Struct.new(:license)
        include Grokdown

        def self.matches_node?(node) = node.type == :document

        def self.aggregate_node(inst, node)
          case node
          when License
            inst.license = node
          end
        end
      end
    README

    run_command("grokdown -e 'Document.new(File.read(\"README.md\")).first.license.name'")
  end

  it { expect(last_command_started).to have_output "MIT License" }
end
