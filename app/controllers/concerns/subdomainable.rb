# Provides a Concern for any Model class entities of which should NEVER be destroyed.
# In model class use it with
#   include Nondeletable
# somewhere inside the model class definition. This guards against "destroy", probably
# not effective against "delete".

module Subdomainable
  extend ActiveSupport::Concern

  private

  def set_app
    @app = App.find_by!(subdomain: subdomain)
  end

  def subdomain
    Subdomain.real_subdomain(request.subdomain)
  end

  def subdomain?
    Subdomain.matches?(request)
  end
end
