require 'app_helper'

class DestroyAppService
  include AppHelper

  def initialize(app)
    @app = app
  end

  def execute
    @app.destroy!.tap do |destroyed|
      FileUtils.rm_rf(app_dir(@app)) if destroyed
    end
  end
end
