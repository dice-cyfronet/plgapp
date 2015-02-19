class CreateAppService
  include AppHelper

  def initialize(app)
    @app = app
  end

  def execute
    @app.save.tap do |saved|
      FileUtils.mkdir_p(app_dir(@app)) if saved
    end
  end
end
