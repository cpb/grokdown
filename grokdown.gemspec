
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "grokdown/version"

Gem::Specification.new do |spec|
  spec.name          = "grokdown"
  spec.version       = Grokdown::VERSION
  spec.authors       = ["Caleb Buxton"]
  spec.email         = ["me@cpb.ca"]

  spec.summary       = \
  spec.description   = %q{Grok Markdown documents with Ruby objects.}
  spec.homepage      = "https://github.com/trykinside/grokdown"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "commonmarker", "~> 0.20.1"
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.12.2"
end
