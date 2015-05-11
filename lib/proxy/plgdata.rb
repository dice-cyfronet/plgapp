require 'resolv'
require 'base64'
require 'proxy/base'

module Proxy
  class Plgdata < Proxy::Base
    def initialize(proxy, _params)
      super(proxy, Rails.configuration.constants['plgdata'])
    end

    protected

    def path(env)
      env['PATH_INFO'].match(/\/plgdata(.*)/)[1]
    end
  end
end
