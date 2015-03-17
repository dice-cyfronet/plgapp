require 'dropbox_sdk'
require 'securerandom'

class DropboxesController < ApplicationController
  load_and_authorize_resource :app,
                              find_by: :subdomain,
                              only: [:update, :destroy]

  skip_before_action :authenticate_user!, only: [:webhook_verify, :delta]
  skip_before_action :verify_authenticity_token, only: :delta

  def update
    current_user.dropbox_access_token ? enable_dropbox(@app) : auth_start
  end

  def destroy
    perform(Dropbox::DisableAppService, @app, I18n.t('dropbox.disconnected'))
  end

  def auth_finish
    app = App.find_by!(subdomain: session[:dropbox_app_subdomain])

    access_token, _ = web_auth.finish(params)
    current_user.update_attributes(dropbox_access_token: access_token)

    enable_dropbox(app)
  rescue DropboxOAuth2Flow::BadRequestError => e
    logger.error(e)
    error(I18n.t('dropbox.bad_request_error'))
  rescue DropboxOAuth2Flow::BadStateError => e
    logger.warn("Error in OAuth 2 flow: No CSRF token in session: #{e}")
    auth_start
  rescue DropboxOAuth2Flow::CsrfError => e
    logger.info("Error in OAuth 2 flow: CSRF mismatch: #{e}")
    error(I18n.t('dropbox.csrf_error'))
  rescue DropboxOAuth2Flow::NotApprovedError
    error(t('dropbox.not_approved_error'))
  rescue DropboxOAuth2Flow::ProviderError => e
    logger.info "Error in OAuth 2 flow: Error redirect from Dropbox: #{e}"
    error(I18n.t('dropbox.provider_error'))
  rescue DropboxError => e
    logger.info "Error getting OAuth 2 access token: #{e}"
    error(I18n.t('dropbox.error'))
  end

  def webhook_verify
    render text: params[:challenge]
  end

  def delta
    Rails.logger.info ":::DELTA >>>>>>>>> #{params}"

    render nothing: true, status: 200
  end

  private

  def enable_dropbox(app)
    perform(Dropbox::EnableAppService, app, I18n.t('dropbox.connected'))
  end

  def perform(service_class, app, success_msg)
    service = service_class.new(current_user, app)
    msg = if service.execute
            { notice: success_msg }
          else
            { alert: I18n.t('dropbox.error') }
          end
    back_to_app(app, msg)
  end

  def back_to_app(app, options)
    redirect_to dropbox_app_deploy_url(app), options
  end

  def error(msg)
    redirect_to(dropbox_app_deploy_url(@app), alert: msg)
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
