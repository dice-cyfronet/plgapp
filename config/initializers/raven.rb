raven_dsn = ENV['RAVEN_DSN']

if raven_dsn
  require 'raven'
  Raven.configure { |config| config.dsn = raven_dsn }
end
