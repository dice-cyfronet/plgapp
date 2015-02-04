# Be sure to restart your server when you modify this file.

if Rails.env.production?
  Rails.application.config.session_store :cookie_store,
                                         key: '_plgapp_session',
                                         expire_after: 40.minutes
else
  Rails.application.config.session_store :cookie_store,
                                         key: '_plgapp_session'
end
