module Dropbox
  class AddJob < ActiveJob::Base
    queue_as :dropbox

    def perform(user, subdomain)
      Dropbox::PushService.new(user, subdomain).execute
    end
  end
end
