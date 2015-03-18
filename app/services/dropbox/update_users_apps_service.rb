module Dropbox
  class UpdateUsersAppsService
    def initialize(users)
      @users = users
    end

    def execute
      @users.each do |user_id|
        Dropbox::UpdateUserAppsJob.perform_later(user_id)
      end
    end
  end
end
