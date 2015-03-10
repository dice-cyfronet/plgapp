class DeploysController < ApplicationController
  load_and_authorize_resource :app, find_by: :subdomain
  before_filter :set_apps, only: [:zip, :dropbox]

  def show
    redirect_to zip_app_deploy_path(@app)
  end

  def zip

  end

  def dropbox

  end

  private

  def set_apps
    @apps = App.accessible_by(current_ability)
  end
end