class AppsController < ApplicationController
  before_filter :set_apps, only: [:index, :new, :show, :edit]
  load_and_authorize_resource find_by: :subdomain

  def index
  end

  def new
  end

  def create
    @app.users << current_user
    if CreateAppService.new(current_user, @app).execute
      redirect_to @app, notice: I18n.t('apps.created')
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if UpdateAppService.new(current_user, @app, app_params).execute
      redirect_to @app, notice: I18n.t('apps.updated')
    else
      redner action: 'edit'
    end
  end

  def show
  end

  def destroy
    DestroyAppService.new(@app).execute
    redirect_to apps_url, notice: I18n.t('apps.removed')
  end

  def download
    path = @app.content.current_path
    send_file path, x_sendfile: true
  end

  private

  def set_apps
    @apps = App.accessible_by(current_ability)
  end

  def app_params
    params.require(:app).
      permit(:name, :subdomain, :login_text, :content)
  end
end
