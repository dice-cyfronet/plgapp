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
    end

    private

    def delete_path
      client.file_delete("/#{@subdomain}")
    rescue DropboxError => e
      raise e unless e.http_response.class == Net::HTTPNotFound
    end
  end
end
