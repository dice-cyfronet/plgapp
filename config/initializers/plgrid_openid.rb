require 'openid/fetchers'

Devise.setup do |config|
  AX = OmniAuth::Strategies::OpenID::AX

  AX[:proxy] = 'http://openid.plgrid.pl/certificate/proxy'
  AX[:userCert] = 'http://openid.plgrid.pl/certificate/userCert'
  AX[:proxyPrivKey] = 'http://openid.plgrid.pl/certificate/proxyPrivKey'
  AX[:POSTresponse] = 'http://openid.plgrid.pl/POSTresponse'

  config.omniauth :open_id,
                  require: 'omniauth-openid',
                  identifier: 'https://openid.plgrid.pl/gateway',
                  required: [
                    AX[:email],
                    AX[:name],
                    AX[:proxy],
                    AX[:userCert],
                    AX[:proxyPrivKey],
                    AX[:POSTresponse]
                  ]

  OpenID.fetcher.ca_file = File.join(Rails.root, 'config', 'ssl',
                                     'DigiCertAssuredIDRootCA.pem')
end

class OpenID::AX::AttrInfo
  def initialize(type_uri, ns_alias = nil, required = false, count = 1)
    @type_uri = type_uri
    @count = count
    @required = required
    @ns_alias = uri_to_alias(type_uri)
  end

  private

  def uri_to_alias(uri)
    case uri
    when 'http://openid.plgrid.pl/certificate/proxy' then 'proxy'
    when 'http://openid.plgrid.pl/certificate/userCert' then 'userCert'
    when 'http://openid.plgrid.pl/certificate/proxyPrivKey' then 'proxyPrivKey'
    when 'http://openid.plgrid.pl/POSTresponse' then 'POSTresponse'
    end
  end
end

class OmniAuth::Strategies::OpenID
  alias old_ax_user_info ax_user_info

  def ax_user_info
    ax = ::OpenID::AX::FetchResponse.from_success_response(openid_response)

    old_ax_user_info.tap do |user_info|
      user_info['proxy'] = get_proxy_element(ax, :proxy)
      user_info['userCert'] = get_proxy_element(ax, :userCert)
      user_info['proxyPrivKey'] = get_proxy_element(ax, :proxyPrivKey)
    end
  end

  private

  def get_proxy_element(ax, id)
    ax.get_single(OmniAuth::Strategies::OpenID::AX[id]).gsub('<br>',"\n")
  end
end
