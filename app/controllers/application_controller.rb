class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :set_session_expiry
  prepend_before_filter :authenticate_user!
  prepend_before_filter :set_locale

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def new_session_path(_scope)
    root_path
  end

  def not_found!
    render 'errors/not_found', layout: 'errors', status: 404
  end

  def not_authorized!
    render 'errors/not_authorized', layout: 'errors', status: 403
  end

  private

  def set_session_expiry
    session_length = Rails.application.config.session_options[:expire_after]
    cookies['session_expiry'] = {
      value: (Time.now + session_length).to_f
    }
  end

  def set_locale
    if language_change_necessary?
      I18n.locale = new_locale
      self.locale_cookie = I18n.locale
    else
      locale_from_cookie
    end
  end

  def new_locale
    locale = params[:locale] || locale_from_accept_language_header
    valid_locale(locale)
  end

  def locale_cookie=(locale)
    cookies['locale'] = {
      value: locale.to_s,
      httponly: true
    }
    current_user.try(:update_attributes, locale: locale.to_s)
  end

  def locale_from_cookie
    I18n.locale = valid_locale(cookies['locale'])
  end

  def valid_locale(locale)
    %w(en pl).include?(locale) ? locale : I18n.default_locale.to_s
  end

  def language_change_necessary?
    cookies['locale'].nil? ||
      params[:locale] ||
      current_user.try(:locale).try(:nil?)
  end

  def locale_from_accept_language_header
    request.
      env['HTTP_ACCEPT_LANGUAGE'].
      scan(/^[a-z]{2}/).first rescue I18n.default_locale
  end
end
