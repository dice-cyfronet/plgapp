module Subdomainable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do
      render 'errors/app_not_found', layout: 'errors', status: 404
    end
  end

  private

  def set_app
    @app = App.find_by!(subdomain: production_subdomain)
  end

  def production_subdomain
    if dev?
      subdomain[0...-Rails.configuration.dev_postfix.length]
    else
      subdomain
    end
  end

  def subdomain
    Subdomain.real_subdomain(request.subdomain)
  end

  def dev?
    @dev = subdomain && subdomain.end_with?(Rails.configuration.dev_postfix)
  end

  def subdomain?
    Subdomain.matches?(request)
  end
end
