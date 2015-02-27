class CreateAppService < AppService
  def execute
    build_activity(:created)

    app.save.tap do |saved|
      FileUtils.mkdir_p(app_dir(app)) if saved
    end
  end
end
