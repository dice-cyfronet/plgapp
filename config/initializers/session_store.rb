# Be sure to restart your server when you modify this file.
#
if Rails.env.test?
  Rails.application.config.
    session_store(:cookie_store,
                  key: '_plgapp_session',
                  expire_after: 40.minutes)
else
  Rails.application.config.
    session_store(:redis_store,
                  # re-use the Redis config from the Rails cache store
                  servers: Plgapp::Application.config.
                           cache_store[1].merge(namespace: 'session:plgapp'),
                  key: '_plgapp_session',
                  secure: true,
                  httponly: true,
                  expire_after: 40.minutes)
end
