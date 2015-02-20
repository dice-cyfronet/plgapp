module Proxyable
  extend ActiveSupport::Concern

  def call
    self.response_body = proxy_responce.body
    self.status = proxy_responce.status
    response.headers = {
      'Content-Type' => proxy_responce.headers['content-type']
    }
  end

  protected

  def proxy_class
    raise 'proxy_class method need to be overriden'
  end

  private

  def proxy
    proxy_class.new(current_user.proxy)
  end

  def proxy_responce
    @proxy_response ||= ActionDispatch::Response.new(*proxy.call(request.env))
  end
end
