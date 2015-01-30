class AppsController < ApplicationController
  before_filter :set_apps, except: :subdomain
  before_filter :set_app, only: [:edit, :show, :destroy, :update]

  def index
  end

  def new
    @app = App.new
  end

  def create
    @app = App.new(app_params)
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

  def subdomain
    @app = App.find_by!(subdomain: request.subdomain)
  end

  private

  def set_apps
    @apps = App.all
  end

  def set_app
    @app = App.find(params[:id])
  end

  def app_params
    params.require(:app).permit(:name, :subdomain)
  end
end
