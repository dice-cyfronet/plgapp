module Proxyable
  extend ActiveSupport::Concern

  def call
    self.response_body = proxy_responce.body
    self.status = proxy_responce.status
    response.headers = response_headers
  end

  protected

  def proxy_class
    raise 'proxy_class method need to be overriden'
  end

  private

  def proxy
    proxy_class.new(session['proxy'], params)
  end

  def proxy_responce
    @proxy_response ||= ActionDispatch::Response.new(*proxy.call(request.env))
  end

  def response_headers
    response.headers.tap do |h|
      if proxy_responce.headers['content-type']
        h['Content-Type'] = proxy_responce.headers['content-type'].join(',')
      end
    end
  end
end
