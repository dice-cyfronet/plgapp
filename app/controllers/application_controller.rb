class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def new_session_path(scope)
    new_user_session_path
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
