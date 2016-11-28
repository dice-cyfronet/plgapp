module Dropbox
  class PushJob < ApplicationJob
    queue_as :dropbox

    def perform(user, app)
      I18n.with_locale(user.locale) do
        check_for_conflict(user, app) if first_push?(user, app)
        push(user, app)
      end
    end

    private

    def check_for_conflict(user, app)
      Dropbox::MoveService.
        new(user, app.subdomain,
            I18n.t('dropbox.dir.collision',
                   name: app.subdomain, time: Time.now)).
        execute
    end

    def first_push?(user, app)
      app_member = app.app_members.find_by(user: user)
      app_member && app_member.dropbox_entries.count == 0
    end

    def push(user, app)
      Dropbox::PushService.new(user, app).execute
    end
  end
end
