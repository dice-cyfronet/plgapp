module Proxyable
  extend ActiveSupport::Concern

  def call
    make_call

    self.response_body = @proxy_response.body
    self.status = @proxy_response.status
    update_content_type
  end

  protected

  def proxy_class
    raise 'proxy_class method need to be overriden'
  end

  private

  def proxy
    proxy_class.new(session['proxy'], params)
  end

  def make_call
    @proxy_response ||= ActionDispatch::Response.
                        new(*proxy.call(request.env.dup))
  end

  def update_content_type
    if @proxy_response.headers['content-type']
      response.set_header('Content-Type',
                          @proxy_response.headers['content-type'])
    end
  end
end
