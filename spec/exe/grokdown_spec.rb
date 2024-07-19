require "spec_helper"

RSpec.describe "grokdown", type: :aruba do
  before do
    write_file "README.md", <<~README_CONTENTS
      # Boyd

      TODO: Delete this and the text below, and describe your gem

      Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/boyd`. To experiment with that code, run `bin/console` for an interactive prompt.

      ## Installation

      TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

      Install the gem and add to the application's Gemfile by executing:

          $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

      If bundler is not being used to manage dependencies, install the gem by executing:

          $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

      ## Usage

      TODO: Write usage instructions here

      ## Development

      After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

      To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

      ## Contributing

      Bug reports and pull requests are welcome on GitHub at https://github.com/cpb/boyd. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/cpb/boyd/blob/main/CODE_OF_CONDUCT.md).

      ## License

      The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

      ## Code of Conduct

      Everyone interacting in the Boyd project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cpb/boyd/blob/main/CODE_OF_CONDUCT.md).
    README_CONTENTS

    write_file ".grokdown", <<~GROKDOWN_CONTENTS
      class Text < String
        include Grokdown

        def self.matches_node?(node) = node.type == :text

        def self.arguments_from_node(node) = node.string_content
      end

      Link = Struct.new(:href, :title, :text, keyword_init: true) do
        include Grokdown

        def self.matches_node?(node) = node.type == :link

        def self.arguments_from_node(node) = {href: node.url, title: node.title}

        def on_text( &block)
          @text_callback = block
        end

        def add_text(new_text)
          return if self[:text]

          @text_callback&.call(new_text)

          self[:text] = new_text
        end
      end

      License = Struct.new(:text, :href, :name, :link, keyword_init: true) do
        include Grokdown

        def self.matches_node?(node) = node.type == :header && node.header_level == 2 && node.first_child.string_content == "License"

        def add_text(node) = self.text = node

        extend Forwardable

        def_delegator :link, :href

        def add_link(link)
          self[:link] = link
          license = self
          link.on_text do |value|
            license.name = value
          end
        end
      end

      Struct.new(:text, :link, :keyword_init) do
        include Grokdown

        def self.matches_node?(node) = node.type == :header && node.header_level == 2

        def add_text(node) = self.text = node
        def add_link(node) = self.link = node
      end

      Readme = Struct.new(:license) do
        include Grokdown

        def self.matches_node?(node) = node.type == :document

        def add_license(node) = self.license = node
      end
    GROKDOWN_CONTENTS
  end

  it "-e 'Document.new(File.read(\"README.md\")).first.license.name' outputs MIT License" do
    run_command("grokdown -e 'Document.new(File.read(\"README.md\")).first.license.name'")
    expect(last_command_started).to have_output "MIT License"
  end
end
