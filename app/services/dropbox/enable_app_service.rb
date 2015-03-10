module Dropbox
  class EnableAppService < AppService

    def execute
      app_member = app.app_members.find_by(user: author)
      if app_member
        app_member.update_attributes(dropbox_enabled: true)

        true
      end
    end
  end
end
