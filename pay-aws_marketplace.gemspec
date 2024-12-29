# frozen_string_literal: true

require_relative "lib/pay/aws_marketplace/version"

Gem::Specification.new do |spec|
  spec.name = "pay-aws_marketplace"
  spec.version = Pay::AwsMarketplace::VERSION
  spec.authors = ["SunChaser.io"]
  spec.email = ["hello@sunchaser.io"]

  spec.summary = "Add support for AWS Marketplace SaaS subscriptions to Pay"
  spec.homepage = "https://sunchaser.io"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sunchaserio/pay-aws_marketplace"
  spec.metadata["changelog_uri"] = spec.metadata["source_code_uri"] + "/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.require_paths = ["lib"]
  spec.add_dependency "aws-sdk-marketplaceentitlementservice", "~> 1.63"
  spec.add_dependency "aws-sdk-marketplacemetering", "~> 1.72"
  spec.add_dependency "pay", ">= 8.3.0"
  spec.add_dependency "zeitwerk", "~> 2.7"
end
