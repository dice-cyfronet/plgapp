require 'resolv'
require 'base64'
require 'proxy/base'

module Proxy
  class Rimrock < Proxy::Base
    def initialize(proxy, _params)
      super(proxy, Rails.configuration.constants['rimrock'])
    end

    protected

    def path(env)
      "/api#{env['PATH_INFO'].match(/\/rimrock(.*)/)[1]}"
    end
  end
end
