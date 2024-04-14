# frozen_string_literal: true

require_relative "lib/grokdown/version"

Gem::Specification.new do |spec|
  spec.name = "grokdown"
  spec.version = Grokdown::VERSION
  spec.authors = ["Caleb Buxton"]
  spec.email = ["me@cpb.ca"]

  spec.summary = \
  spec.description = %q{Grok Markdown documents with Ruby objects.}
  spec.homepage = "https://github.com/cpb/grokdown"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CODE_OF_CONDUCT.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "commonmarker", "~> 0.20.1"
end
