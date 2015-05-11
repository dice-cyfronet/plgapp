require 'resolv'
require 'base64'
require 'proxy/base'

module Proxy
  class Datanet < Proxy::Base
    def initialize(proxy, params)
      @repo_name = params[:repo_name]
      super(proxy, repo_url)
    end

    def rewrite_env(env)
      super(env).tap do |e|
        e['HTTP_GRID_PROXY'] = e.delete('HTTP_PROXY')
        e['HTTP_HOST'] = repo_host
      end
    end

    protected

    def path(env)
      "/#{match(env)[2]}"
    end

    private

    def repo_url
      "#{uri.scheme}://#{repo_host}"
    end

    def repo_host
      "#{@repo_name}.#{uri.host}"
    end

    def uri
      @uri ||= URI(Rails.configuration.constants['datanet'])
    end

    def match(env)
      env['PATH_INFO'].match(%r{/datanet/(.[^/]*)/(.*)})
    end
  end
end
