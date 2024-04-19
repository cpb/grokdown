# frozen_string_literal: true

require "grokdown"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # TODO: consider a builder of an instance/singleton
  config.around(:each) do |example|
    old_knowns = Grokdown::Matching.class_variable_get(:@@knowns)
    Grokdown::Matching.class_variable_set(:@@knowns, [])
    example.run
    Grokdown::Matching.class_variable_set(:@@knowns, old_knowns)
  end
end
