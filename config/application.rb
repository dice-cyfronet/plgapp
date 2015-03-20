require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Plgapp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Custom error pages
    config.exceptions_app = routes

    # Use sidekiq as delayed job adapter.
    config.active_job.queue_adapter = :sidekiq

    # Load application-specific constants from a config file
    config.constants = config_for(:application)

    postfix = config.constants['domain_prefix']
    postfix = postfix ? "\.#{postfix}" : ''
    config.subdomain_regexp = /\A(www.)?([\w-]*){1}#{postfix}\z/

    config.apps_dir = config.constants['apps_dir']
    config.dev_postfix = config.constants['dev_postfix']

    config.dropbox = Struct.new(:app_key, :app_secret).
      new(ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET'])
  end
end
