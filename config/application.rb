require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Plgapp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

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

    redis_url_string = config.constants['redis_url'] || 'redis://localhost:6379'

    # Redis::Store does not handle Unix sockets well, so let's do it for them
    redis_config_hash = Redis::Store::Factory.
                        extract_host_options_from_uri(redis_url_string)
    redis_uri = URI.parse(redis_url_string)
    redis_config_hash[:path] = redis_uri.path if redis_uri.scheme == 'unix'

    redis_config_hash[:namespace] = 'cache:plgapp'
    redis_config_hash[:expires_in] = 2.weeks # Cache should not grow forever
    config.cache_store = :redis_store, redis_config_hash
  end
end
