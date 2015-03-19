module Dropbox
  class DisableAppService < AppService
    def execute
      app_member = app.app_members.find_by(user: author)
      if app_member
        app_member.update_attributes(dropbox_enabled: false).tap do |success|
          Dropbox::DeleteJob.perform_later(author, app.subdomain) if success
        end
      end
    end
  end
end
