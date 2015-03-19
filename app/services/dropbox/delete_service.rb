module Dropbox
  class DeleteService < Operation
    def initialize(author, subdomain, options = {})
      app = author.apps.find_by(subdomain: subdomain)
      @subdomain = subdomain

      super(author, app, options)
    end

    def execute
      client.file_delete("/#{@subdomain}")
      app_member.dropbox_entries.destroy_all if app_member
    end
  end
end
