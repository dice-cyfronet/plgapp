module Dropbox
  class DeleteService < Operation
    def initialize(author, subdomain, options = {})
      app = author.apps.find_by(subdomain: subdomain)
      @subdomain = subdomain

      super(author, app, options)
    end

    def execute
      delete_path
      disable_dropbox
      clean_cursor

      clean_dropbox_account unless has_dropbox_app?
    end

    private

    def delete_path
      client.file_move("/#{@subdomain}",
                       "/#{@subdomain} (detached at #{Time.now})")
    rescue DropboxError => e
      raise e unless e.http_response.class == Net::HTTPNotFound
    end

    def disable_dropbox
      if app_member
        app_member.dropbox_entries.destroy_all
        app_member.update_attributes(dropbox_enabled: false)
      end
    end

    def has_dropbox_app?
      author.dropbox_apps.count > 0
    end

    def clean_dropbox_account
      author.clean_dropbox_account!
    end

    def clean_cursor
      app_member.update_attributes(dropbox_cursor: nil) if app_member
    end
  end
end
