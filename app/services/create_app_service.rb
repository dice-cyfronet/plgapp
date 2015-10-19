class CreateAppService < AppService
  def execute
    build_activity(:created)
    app.app_members.build(user: author, role: :master)
    app.save.tap do |saved|
      if saved
        FileUtils.mkdir_p(app_dir(app))
        FileUtils.mkdir_p(app_dev_dir(app))
      end
    end
  end
end
