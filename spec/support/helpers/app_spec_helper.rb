require 'app_helper'

module AppSpecHelper
  include AppHelper

  def with_app(app = nil)
    app ||= create_app
    yield app
  ensure
    FileUtils.rm_rf(app_dir(app))
  end

  def create_app
    build(:app).tap do |app|
      CreateAppService.new(app).execute
    end
  end

  def app_file_path(app, file_path)
    Pathname.new(Rails.configuration.apps_dir).
      join(app.subdomain, file_path)
  end
end