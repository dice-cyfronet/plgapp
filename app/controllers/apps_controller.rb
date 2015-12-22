class AppsController < ApplicationController
  before_action :set_apps,
                only: [:index, :new, :show, :edit, :deploy, :activity]

  load_and_authorize_resource find_by: :subdomain

  def index
  end

  def new
  end

  def create
    if CreateAppService.new(current_user, @app).execute
      redirect_to @app, notice: I18n.t('apps.created')
    else
      set_apps
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if UpdateAppService.new(current_user, @app, app_params).execute
      redirect_to @app, notice: I18n.t('apps.updated')
    else
      set_apps
      render action: 'edit'
    end
  end

  def show
  end

  def deploy
  end

  def activity
    @activities = @app.activities.order(created_at: :desc)
  end

  def destroy
    DestroyAppService.new(@app).execute
    redirect_to apps_url, notice: I18n.t('apps.removed')
  end

  def download
    path = @app.content.current_path
    send_file path, x_sendfile: true
  end

  def push
    if PushToProductionService.new(current_user, @app, message: msg).execute
      redirect_to [:zip, @app, :deploy], notice: I18n.t('apps.pushed')
    else
      redirect_to [:zip, @app, :deploy], alert: I18n.t('apps.push_error')
    end
  end

  private

  def set_apps
    @apps = App.accessible_by(current_ability)
  end

  def app_params
    params.require(:app).
      permit(:name, :subdomain, :login_text, :content, :logo)
  end

  def msg
    params[:msg]
  end
end
