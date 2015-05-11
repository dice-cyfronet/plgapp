require 'proxy/datanet'

class DatanetController < ApplicationController
  include Proxyable

  protected

  def proxy_class
    Proxy::Datanet
  end
end
