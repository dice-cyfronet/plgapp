require 'proxy/plgdata'

class PlgdataController < ApplicationController
  include Proxyable

  protected

  def proxy_class
    Proxy::Plgdata
  end
end
