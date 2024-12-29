# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("dummy/config/environment.rb", __dir__)
ActiveRecord::Migrator.migrations_paths = [
  File.expand_path("dummy/db/migrate", __dir__),
  File.expand_path("../db/migrate", __dir__)
]
ActiveRecord::Migration.maintain_test_schema!

require "rspec/rails"
require "pay/aws_marketplace"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.fixture_paths = [File.expand_path("fixtures", __dir__)]
  config.include ActiveSupport::Testing::TimeHelpers
end
