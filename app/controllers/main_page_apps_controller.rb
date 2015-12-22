class MainPageAppsController < ApplicationController
  def index
    @apps = App.all
  end
end
