module Dropbox
  class DeleteService < Operation
    def initialize(author, subdomain, options = {})
      app = author.apps.find_by(subdomain: subdomain)
      @subdomain = subdomain

      super(author, app, options)
    end

    def execute
      delete_path
      app_member.dropbox_entries.destroy_all if app_member
      clean_dropbox_account if has_dropbox_app?
    end

    private

    def delete_path
      client.file_delete("/#{@subdomain}")
    rescue DropboxError => e
      raise e unless e.http_response.class == Net::HTTPNotFound
    end

    def has_dropbox_app?
      author.apps.joins(:app_members).
        where(app_members: { dropbox_enabled: true }).
        count
    end

    def clean_dropbox_account
      author.update_attributes(dropbox_access_token: nil,
                               dropbox_user: nil)
    end
  end
end
