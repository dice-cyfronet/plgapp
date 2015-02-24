require 'resolv'
require 'base64'

module Proxy
  class Base < Rack::Proxy
    def initialize(proxy, destination)
      super(ssl_verify_none: true, backend: destination)

      @proxy = proxy
    end

    def rewrite_env(env)
      env.tap do |e|
        e['HTTP_PROXY'] = proxy
        e['PATH_INFO'] = path(e)
      end
    end

    protected

    # Overide if path should be modified.
    def path(env)
      env['PATH_INFO']
    end

    private

    def proxy
      Base64.encode64(@proxy).gsub!(/\s+/, '')
    end
  end
end