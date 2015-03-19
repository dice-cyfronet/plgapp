require 'app_helper'

class DestroyAppService
  include AppHelper

  def initialize(app)
    @app = app
  end

  def execute
    dropbox_users = app.users.joins(:app_members).
                    where(app_members: { dropbox_enabled: true }).to_a

    app.destroy!.tap do
      FileUtils.rm_rf(app_dir(app))
      FileUtils.rm_rf(app_dev_dir(app))
      remove_from_dropbox_for(dropbox_users)
    end
  end

  private

  attr_reader :app

  def remove_from_dropbox_for(users)
    users.each { |u| Dropbox::DeleteJob.perform_later(u, app.subdomain) }
  end
end
