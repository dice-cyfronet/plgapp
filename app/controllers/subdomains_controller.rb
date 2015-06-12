class SubdomainsController < ApplicationController
  include Subdomainable

  skip_before_action :verify_authenticity_token
  prepend_before_filter :set_app
  before_filter :app_authorize!

  def show
    unless session[:_csrf_token]
      form_authenticity_token
    end

    if file && file.exist?
      send_file file, disposition: 'inline'
    else
      not_found!
    end
  end

  def info
    render json: {
      csrfToken: form_authenticity_token,
      userLogin: current_user.login,
      development: dev?
    }
  end

  private

  def app_authorize!
    action = dev? ? :dev_view : :view

    unless can?(action, @app)
      not_authorized!
    end
  end

  def file
    @file ||= GetAppFileService.new(@app, dev?, params[:id]).execute
  end
end
