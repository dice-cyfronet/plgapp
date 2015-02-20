require 'app_helper'

module AppSpecHelper
  include AppHelper

  def with_app(app)
    yield
    FileUtils.rm_rf(app_dir(app))
  end
end