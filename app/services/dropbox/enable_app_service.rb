module Dropbox
  class EnableAppService < AppService
    def execute
      app_member = app.app_members.find_by(user: author)
      if app_member
        app_member.update_attributes(dropbox_enabled: true).tap do |success|
          Dropbox::PushJob.perform_later(author, app) if success
        end
      end
    end
  end
end
