module Dropbox
  class DisableAppService < AppService

    def execute
      app_member = app.app_members.find_by(user: author)
      if app_member
        app_member.update_attributes(dropbox_enabled: false)
        remove_dropbox_token_if_last_app

        true
      end
    end

    private

    def remove_dropbox_token_if_last_app
      if author.app_members.where(dropbox_enabled: true).count == 0
        author.update_attributes(dropbox_access_token: nil)
      end
    end
  end
end
