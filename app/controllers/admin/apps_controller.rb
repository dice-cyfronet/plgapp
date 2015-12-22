module Admin
  class AppsController < ApplicationController
    before_filter :set_apps

    load_resource :app, find_by: :subdomain

    def index
    end

    def show
    end

    def update
      if @app.update_attributes(app_params)
        redirect_to [:admin, @app], notice: I18n.t('apps.updated')
      else
        set_apps
        render action: 'show'
      end
    end

    private

    def set_apps
      @apps = App.all.order(:name)
    end

    def app_params
      params.require(:app).
        permit(:show_on_main_page)
    end
  end
end
