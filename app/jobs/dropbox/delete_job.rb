module Dropbox
  class DeleteJob < ApplicationJob
    queue_as :dropbox

    def perform(user, subdomain)
      Dropbox::DeleteService.new(user, subdomain).execute
    end
  end
end
