# Grokdown

Deserialize Markdown to Ruby objects.

## Usage

- Extracting License information from README.md

```ruby
require "grokdown"

class Text < String
  include Grokdown

  def consumes?(*) = false

  match { |node| node.type == :text }
  create { |node| node.string_content }
end

class Link < Struct.new(:href, :title, :text, keyword_init: true)
  include Grokdown

  match { |node| node.type == :link }
  create { |node| {href: node.url, title: node.title} }
  consumes Text => :text=

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

  match { |node| node.type == :header && node.header_level == 2 && node.first_child.string_content == "License" }
  consumes Text => :text=, Link => :link=

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

  match { |node| node.type == :header && node.header_level == 2 }
  consumes Text => :text=, Link => :link=
end

class Readme < Struct.new(:license)
  include Grokdown

  match { |node| node.type == :document }

  consumes License => :license=
end

readme = Grokdown::Document.new(File.read("README.md")).first

puts readme.license.name
# fetch license at url
readme.license.href
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add grokdown

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install grokdown

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cpb/grokdown. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/cpb/grokdown/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Grokdown project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cpb/grokdown/blob/main/CODE_OF_CONDUCT.md).
