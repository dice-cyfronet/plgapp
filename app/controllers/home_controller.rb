class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @apps = App.for_main_page
    @show_apps = @apps.count > 0
  end
end
