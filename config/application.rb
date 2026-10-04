require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ECommerce
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_storage.replace_on_assign_to_many = false
    config.active_job.queue_adapter = :sidekiq
    # sassc-rails defaults the CSS compressor to :sass (libsass, EOL), which cannot
    # parse modern CSS such as ActiveAdmin 4's Tailwind v4 output (`rgb(from ...)`).
    # Our Tailwind build is already minified, so skip the sass compressor entirely.
    config.assets.css_compressor = nil
  end
end
