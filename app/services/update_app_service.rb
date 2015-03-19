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
    content_changed = app.content_changed?

    app.save!.tap do
      new_app_dir = app_dir(app)
      if old_app_dir != new_app_dir
        FileUtils.mv(old_app_dir, new_app_dir)
        FileUtils.mv(old_app_dev_dir, app_dev_dir(app))
      end

      dropbox_app_users.each { |u| Dropbox::PushJob.perform_later(u, app) }
    end
  end

  private

  def dropbox_app_users
    app.users.joins(:app_members).where(app_members: { dropbox_enabled: true })
  end
end
