# Grokdown: Markdown to Ruby Objects

`Grokdown` provides **an experimental interface** for building value objects and composing them into entities from a Markdown document tree.

## Usage

Include the `Grokdown` module into ruby classes you want `Grokdown::Document` to consider building value objects from.

`Grokdown::Document` depends on class methods `matches_node?` and `agruments_from_node` to select which `Grokdown` class to build and how to build an instance from a Markdown node.

`Grokdown` instances can compose `Grokdown` value objects or entities by implementing instance hook methods following a naming convention. The hook method name is `add_` prefixing the snake case `Grokdown` class name of the instances a `Grokdown` instance can get added.

Implementing the hook methods creates precise and resilient factories for objects from Markdown documents.

Receiver | Hook method | Use case
--- | --- | ---
Class | `matches_node?` | Predicate to select receiving class to build from a given Markdown node|
Class | `arguments_from_node` | Maps node values to build an instance of the class from a given Markdown node |
Instance | `add_other_class_name` | Aggregate later `OtherClassName` instances when visiting the Markdown node tree |

Simple differences in implementations of `add_` composition methods enables building useful ruby object graphs from easy to write Markdown files.

### Extracting License information from README.md

Create a `.grokdown` file which defines types to build from markdown nodes, then use the `grokdown` CLI to extract the license name with:

```sh
grokdown -e "Document.new(File.read('README.md')).first.license.name"
```

##### `README.md`

```
# Example Readme

Simple readme with a conventional `## License` section

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
```

##### `.grokdown`

```ruby
require "grokdown"

class Text < String
  include Grokdown

  def self.matches_node?(node) = node.type == :text

  def self.arguments_from_node(node) = node.string_content
end

Link = Struct.new(:href, :title, :text, :parent, keyword_init: true) do
  include Grokdown

  def self.matches_node?(node) = node.type == :link

  def self.arguments_from_node(node) = {href: node.url, title: node.title}

  def add_text(node)
    return if text

    self.text = node

    parent.add_composable(node) if parent&.can_compose?(node)
  end
end

License = Struct.new(:text, :href, :name, :link, keyword_init: true) do
  include Grokdown

  def self.matches_node?(node) = node.type == :header && node.header_level == 2 && node.first_child.string_content == "License"

  def add_text(node) = self.text = node

  extend Forwardable

  def_delegator :link, :href

  def add_link(node)
    node.parent = self
    self.link = node
  end

  def add_text(node) = self.name = node
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
