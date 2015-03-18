module Dropbox
  class UpdateUserAppJob < ActiveJob::Base
    queue_as :dropbox

    def perform(user, app)
      pull = Dropbox::PullService.new(user, app)

      if pull.execute
        affected_users(user, app).each do |affected_user|
          Dropbox::PushService.new(affected_user, app).execute
        end
      end
    end

    private

    def affected_users(author, app)
      users = User.joins(:app_members).
              where(app_members: { dropbox_enabled: true, app_id: app.id })

      users - [author]
    end
  end
end
