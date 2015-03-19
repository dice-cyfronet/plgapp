module Dropbox
  class UpdateUsersAppsService
    def initialize(dropbox_users_ids)
      @users = User.where(dropbox_user: dropbox_users_ids)
    end

    def execute
      @users.each do |user|
        apps = App.joins(:app_members).
               where(app_members: { user_id: user.id, dropbox_enabled: true })

        apps.each { |app| Dropbox::UpdateUserAppJob.perform_later(user, app) }
      end
    end
  end
end
