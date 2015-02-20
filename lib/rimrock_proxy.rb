require 'resolv'
require 'base64'

class RimrockProxy < Rack::Proxy
  def initialize(proxy)
    super(ssl_verify_none: true,
          backend: Rails.configuration.constants['rimrock'])

    @proxy = proxy
  end

  def rewrite_env(env)
    env.tap do |e|
      e['HTTP_PROXY'] = proxy
      e['PATH_INFO'] = path(e)
    end
  end

  private

  def proxy
    Base64.encode64(@proxy).gsub!(/\s+/, '')
  end

  def path(env)
    "/api#{env['PATH_INFO'].match(/\/rimrock(.*)/)[1]}"
  end
end
