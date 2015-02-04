# Be sure to restart your server when you modify this file.

if Rails.env.production?
  Rails.application.config.session_store :cookie_store,
                                         key: '_plgapp_session',
                                         expire_after: 40.minutes
else
  Rails.application.config.session_store :cookie_store,
                                         key: '_plgapp_session'
end

# Clearing user proxy from DB on logout, if session still exists
Warden::Manager.before_logout do |user, auth, opts|
  user.clear_proxy if user
end
