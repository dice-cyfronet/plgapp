require 'rimrock_proxy'

class RimrockController < ApplicationController
  def call
    self.response_body = proxy_responce.body
    self.status = proxy_responce.status
    response.headers = {
      'Content-Type' => proxy_responce.headers['content-type']
    }
  end

  private

  def proxy
    RimrockProxy.new(current_user.proxy)
  end

  def proxy_responce
    @proxy_response ||= ActionDispatch::Response.new(*proxy.call(request.env))
  end
end
