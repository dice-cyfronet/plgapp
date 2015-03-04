require 'app_helper'

class DestroyAppService
  include AppHelper

  def initialize(app)
    @app = app
  end

  def execute
    @app.destroy!.tap do |destroyed|
      if destroyed
        FileUtils.rm_rf(app_dir(@app))
        FileUtils.rm_rf(app_dev_dir(@app))
      end
    end
  end
end
