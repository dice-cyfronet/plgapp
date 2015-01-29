require 'openid/fetchers'

Devise.setup do |config|
  config.omniauth :open_id,
                  require: 'omniauth-openid',
                  identifier: 'https://openid.plgrid.pl/gateway'

  OpenID.fetcher.ca_file = File.join(Rails.root, 'config', 'ssl', 'plg-ca.crt')
end
