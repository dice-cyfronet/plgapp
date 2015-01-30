class AppsController < ApplicationController
  def index
  end

  def show
    @app = App.find_by!(subdomain: request.subdomain)
  end
end
