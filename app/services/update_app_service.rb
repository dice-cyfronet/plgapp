class UpdateAppService < AppService
  def initialize(author, app, params)
    super(author, app)
    @params = params
  end

  def execute
    old_app_dir = app_dir(app)
    app.assign_attributes(@params)

    build_activity(:updated) if app.update?
    build_activity(:deployment) if app.deploy?

    app.save.tap do |updated|
      new_app_dir = app_dir(app)
      if updated && old_app_dir != new_app_dir
        FileUtils.mv(old_app_dir, new_app_dir)
      end
    end
  end
end
