require 'dropbox_sdk'
require 'securerandom'

class DropboxesController < ApplicationController
  load_and_authorize_resource :app, find_by: :subdomain, only: :show

  def show
    if current_user.dropbox_access_token
      redirect_to dropbox_app_deploy_path(@app)
    else
      auth_start
    end
  end

  def auth_finish
    app = App.find_by!(subdomain: session[:dropbox_app_subdomain])

    access_token, _user_id, _url_state = web_auth.finish(params)
    current_user.update_attributes(dropbox_access_token: access_token)

    redirect_to dropbox_app_deploy_path(app)

  rescue DropboxOAuth2Flow::BadRequestError => e
      logger.error(e)
      error(t('dropbox.bad_request_error'))
  rescue DropboxOAuth2Flow::BadStateError => e
      logger.warn("Error in OAuth 2 flow: No CSRF token in session: #{e}")
      auth_start
  rescue DropboxOAuth2Flow::CsrfError => e
      logger.info("Error in OAuth 2 flow: CSRF mismatch: #{e}")
      error(t('dropbox.csrf_error'))
  rescue DropboxOAuth2Flow::NotApprovedError => e
      error(t('dropbox.not_approved_error'))
  rescue DropboxOAuth2Flow::ProviderError => e
      logger.info "Error in OAuth 2 flow: Error redirect from Dropbox: #{e}"
      error(t('dropbox.provider_error'))
  rescue DropboxError => e
      logger.info "Error getting OAuth 2 access token: #{e}"
      error(t('dropbox.error'))
  end

  private

  def error
    redirect_to(dropbox_app_deploy_path(@app), alert: msg)
  end

  def auth_start
    session[:dropbox_app_subdomain] = @app.subdomain
    redirect_to web_auth.start
  end

  def web_auth
    dropbox_conf = Rails.configuration.dropbox

    DropboxOAuth2Flow.new(dropbox_conf.app_key,
                          dropbox_conf.app_secret,
                          dropbox_auth_finish_url,
                          session, :dropbox_auth_csrf_token)
  end
end
