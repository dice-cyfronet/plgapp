require 'proxy/datanet'

class DatanetController < ApplicationController
  before_action :repo_name_invalid, unless: :valid_repo_name?

  include Proxyable

  protected

  def proxy_class
    Proxy::Datanet
  end

  def valid_repo_name?
    /^([a-zA-Z\d]+(-[a-zA-Z\d]+)*)$/ =~ params[:repo_name]
  end

  def repo_name_invalid
    render(json: { error: I18n.t('errors.wrong_repo_name') },
           status: :bad_request)
  end
end
