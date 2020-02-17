# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)
require "flow_core"

# Require monkey patches
Dir[Pathname.new(File.dirname(__FILE__)).realpath.parent.join("lib", "patches", "*.rb")].map do |file|
  require file
end

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |g|
      g.helper false
      g.assets false
      g.test_framework nil
    end

    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]

    overrides = Rails.root.join("app/overrides")
    Rails.autoloaders.main.ignore(overrides)
    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").each do |override|
        load override
      end
    end
  end
end
