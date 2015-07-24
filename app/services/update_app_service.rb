class UpdateAppService < AppService
  def initialize(author, app, params)
    super(author, app)
    @params = params
  end

  def execute
    app.assign_attributes(@params)

    build_activity(:updated) if app.update?
    content_changed = app.content_changed?

    app.save.tap do |success|
      if success
        old_app_dir = app_dir(app.old_subdomain)
        new_app_dir = app_dir(app)
        if old_app_dir != new_app_dir
          FileUtils.mv(old_app_dir, new_app_dir)
          FileUtils.mv(app_dev_dir(app.old_subdomain), app_dev_dir(app))
          dbox_app_users.each do |u|
            Dropbox::MoveJob.perform_later(u, app.old_subdomain, app.subdomain)
          end
        end

        if content_changed
          dbox_app_users.each { |u| Dropbox::PushJob.perform_later(u, app) }
        end
      end
    end
  end

  private

  def dbox_app_users
    app.users.joins(:app_members).where(app_members: { dropbox_enabled: true })
  end
end
