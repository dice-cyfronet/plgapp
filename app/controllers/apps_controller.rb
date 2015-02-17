class AppsController < ApplicationController
  before_filter :set_apps, only: [:index, :new, :show, :edit]
  load_and_authorize_resource

  def index
  end

  def new
  end

  def create
    @app.users << current_user
    if @app.save
      redirect_to @app, notice: I18n.t('apps.created')
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @app.update(app_params)
      redirect_to @app, notice: I18n.t('apps.updated')
    else
      redner action: 'edit'
    end
  end

  def show
  end

  def destroy
    @app.destroy!
    redirect_to apps_url, notice: I18n.t('apps.removed')
  end

  private

  def set_apps
    @apps = App.accessible_by(current_ability)
  end

  def app_params
    params.require(:app).
      permit(:name, :subdomain, :login_text)
  end
end
