# Support for Rspec / Capybara subdomain integration testing
# Make sure this file is required by spec_helper.rb
# (e.g. save as spec/support/subdomains.rb)

def switch_to_subdomain(subdomain)
  # lvh.me always resolves to 127.0.0.1
  hostname = subdomain ? "#{subdomain}.lvh.me" : "lvh.me"
  Capybara.app_host = "http://#{hostname}"
  Capybara.default_host = "http://#{hostname}"
end

def switch_to_main_domain
  switch_to_subdomain nil
end

def in_subdomain(subdomain)
  switch_to_subdomain(subdomain)
  yield
ensure
  switch_to_main_domain
end

def logged_in_subdomain(subdomain, options = {})
  custom_app = create(:app, subdomain: subdomain)
  user = options[:user] || create(:user, apps: [custom_app])

  switch_to_subdomain(app_full_path(custom_app, options[:dev]))
  login_as(user, scope: :user)
  yield user, custom_app
ensure
  switch_to_main_domain
end

def app_full_path(app, dev)
  dev ? app.dev_full_subdomain : app.full_subdomain
end

RSpec.configure do |config|
  switch_to_main_domain
end

Capybara.configure do |config|
  config.always_include_port = true
end
