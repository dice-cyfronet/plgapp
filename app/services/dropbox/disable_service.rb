module Dropbox
  class DisableService
    def initialize(user)
      @user = user
    end

    def execute
      clear_dropbox_credentials
      disconnect_all_user_apps
      notify_user
    end

    private

    attr_reader :user

    def clear_dropbox_credentials
      user.clean_dropbox_account!
    end

    def disconnect_all_user_apps
      dropbox_app_members.each { |app| disconnect(app) }
    end

    def dropbox_app_members
      user.app_members.where(dropbox_enabled: true)
    end

    def disconnect(app_member)
      app_member.update_attributes(dropbox_enabled: false, dropbox_cursor: nil)
      app_member.dropbox_entries.delete_all
    end

    def notify_user
      AppMailer.dropbox_disconnect_email(@user).deliver_later
    end
  end
end
