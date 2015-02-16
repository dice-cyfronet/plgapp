class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_filter :set_locale

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def new_session_path(scope)
    new_user_session_path
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  private

  def set_locale
    if language_change_necessary?
      I18n.locale = new_locale
      set_locale_cookie(I18n.locale)
    else
      locale_from_cookie
    end
  end

  def new_locale
    locale = params[:locale] || locale_from_accept_language_header
    ['en', 'pl'].include?(locale) ? locale : I18n.default_locale.to_s
  end

  def set_locale_cookie(locale)
    cookies['locale'] = locale.to_s
  end

  def locale_from_cookie
    I18n.locale = cookies['locale']
  end

  def language_change_necessary?
    return cookies['locale'].nil? || params[:locale]
  end

  def locale_from_accept_language_header
    locale = request.
              env['HTTP_ACCEPT_LANGUAGE'].
              scan(/^[a-z]{2}/).first rescue I18n.default_locale
  end
end
