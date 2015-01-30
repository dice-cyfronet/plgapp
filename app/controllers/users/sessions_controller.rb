class Users::SessionsController < Devise::SessionsController
  before_filter :set_app, only: :new, if: :subdomain?

  private

  def set_app
    @app = App.find_by!(subdomain: request.subdomain)
  end

  def subdomain?
    Subdomain.matches?(request)
  end
end