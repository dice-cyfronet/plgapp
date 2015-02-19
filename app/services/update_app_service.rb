class UpdateAppService
  include AppHelper

  def initialize(app, params)
    @app = app
    @params = params
  end

  def execute
    old_app_dir = app_dir(@app)
    @app.update(@params).tap do |updated|
      new_app_dir = app_dir(@app)
      if updated && old_app_dir != new_app_dir
        FileUtils.mv(old_app_dir, new_app_dir)
      end
    end
  end
end
