require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)
require "pay"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_job.queue_adapter = :test
    config.action_mailer.default_url_options = {host: "localhost", port: 3000}

    # Remove warnings
    config.active_record.legacy_connection_handling = false if Rails.gem_version >= Gem::Version.new("6.1") && Rails.gem_version < Gem::Version.new("7.1.0.alpha")

    # Set the ActionMailer preview path to the gem test directory
    config.action_mailer.show_previews = true

    if Rails.gem_version >= Gem::Version.new("7.1.0.alpha")
      config.action_mailer.preview_paths << Rails.root.join("../../test/mailers/previews")
    else
      config.action_mailer.preview_path = Rails.root.join("../../test/mailers/previews")
    end

    # Opt in to 8.1 behavior to suppress a warning
    config.active_support.to_time_preserves_timezone = :zone
  end
end
