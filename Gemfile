source 'https://rubygems.org'

gem 'rails', '4.2.0'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'turbolinks'

gem 'bootstrap-sass', '~> 3.3.1'
gem 'font-awesome-sass', '~> 4.3.0'
gem 'autoprefixer-rails'

gem 'haml-rails'
gem 'simple_form'
gem 'carrierwave'
gem 'rubyzip'
gem 'redcarpet'

gem 'devise'
gem 'ruby-openid', '~> 2.6.0'
gem 'omniauth-openid'
gem 'cancancan'
gem 'friendly_id'

gem 'puma'

gem 'rack-proxy'

gem 'newrelic_rpm'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'rspec-rails', '~> 3.0'

  # PLG OpenId requires ssh even for development
  # start app using `thin start --ssl`
  gem 'thin'
end

group :test do
  gem 'spring-commands-rspec'
  gem 'capybara'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'shoulda-matchers', require: false
  gem 'guard-rspec', require: false
  gem 'database_cleaner'
  gem 'faker'
  gem "codeclimate-test-reporter", require: nil
end