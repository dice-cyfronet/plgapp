module Dropbox
  class DeleteService < Operation
    def initialize(author, subdomain, options = {})
      app = author.apps.find_by(subdomain: subdomain)
      @subdomain = subdomain
      @options = options

      super(author, app, options)
    end

    protected

    def internal_execute
      delete_path
      disable_dropbox

      clean_dropbox_account unless has_dropbox_app?
    end

    private

    def delete_path
      Dropbox::MoveService.new(author,
                               @subdomain,
                               "#{@subdomain} (detached at #{Time.now})",
                               @options).execute
    end

    def disable_dropbox
      if app_member
        app_member.dropbox_entries.destroy_all
        app_member.update_attributes(dropbox_enabled: false,
                                     dropbox_cursor: nil)
      end
    end

    def has_dropbox_app?
      author.dropbox_apps.count > 0
    end

    def clean_dropbox_account
      author.clean_dropbox_account!
    end
  end
end
