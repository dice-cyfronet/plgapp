require 'app_helper'

module AppSpecHelper
  include Warden::Test::Helpers
  include AppHelper

  def with_app(app = nil)
    app ||= create_app
    yield app
  ensure
    FileUtils.rm_rf(app_dir(app))
  end

  def create_app(author = create(:user))
    build(:app).tap do |app|
      CreateAppService.new(author, app).execute
    end
  end

  def app_file_path(app, file_path)
    Pathname.new(Rails.configuration.apps_dir).
      join(app.subdomain, file_path)
  end

  def app_owner_log_in(app)
    owner = create(:user)
    app.users << owner
    login_as(owner, scope: :user)
  end
end
