class SubdomainsController < ApplicationController
  include Subdomainable

  skip_before_action :verify_authenticity_token
  before_filter :set_app

  def show
    if file && file.exist?
      send_file file, disposition: 'inline'
    else
      not_found!
    end
  end

  def info
    render json: {
      csrfToken: form_authenticity_token,
      userLogin: current_user.login
    }
  end

  private

  def file
    @file ||= GetAppFileService.new(@app, dev?, params[:id]).execute
  end
end
