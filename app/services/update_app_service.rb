class UpdateAppService < AppService
  def initialize(author, app, params)
    super(author, app)
    @params = params
  end

  def execute
    old_app_dir = app_dir(app)
    old_app_dev_dir = app_dev_dir(app)
    app.assign_attributes(@params)

    build_activity(:updated) if app.update?

    app.save.tap do |updated|
      new_app_dir = app_dir(app)
      if updated && old_app_dir != new_app_dir
        FileUtils.mv(old_app_dir, new_app_dir)
        FileUtils.mv(old_app_dev_dir, app_dev_dir(app))
      end
    end
  end
end
