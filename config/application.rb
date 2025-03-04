require_relative "boot"

require "rails/all"
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate-bootstrap'
require 'discard'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CommunityConnectExp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    #setting up the default locale
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es]
    config.i18n.raise_on_missing_translations = true

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    
    config.autoload_lib(ignore: %w[assets tasks])
    config.action_dispatch.rescue_responses["Turbo::Streams::HTMLRequest"] = :not_acceptable

    config.time_zone = 'Asia/Kolkata'  # Change this to your preferred timezone
    config.active_record.default_timezone = :local


    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
