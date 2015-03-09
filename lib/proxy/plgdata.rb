require 'resolv'
require 'base64'
require 'proxy/base'

module Proxy
  class Plgdata < Proxy::Base
    def initialize(proxy)
      super(proxy, Rails.configuration.constants['plgdata'])
    end

    def rewrite_env(env)
      super.tap do |e|
        e['HTTP_ACCEPT'] = "*/*" if e['PATH_INFO'].start_with?('/upload')
      end
    end

    protected

    def path(env)
      env['PATH_INFO'].match(/\/plgdata(.*)/)[1]
    end
  end
end
