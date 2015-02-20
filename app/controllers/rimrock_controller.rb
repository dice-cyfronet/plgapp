require 'proxy/rimrock'

class RimrockController < ApplicationController
  include Proxyable

  protected

  def proxy_class
    Proxy::Rimrock
  end
end
