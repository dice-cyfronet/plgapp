module Dropbox
  class PushJob < ActiveJob::Base
    queue_as :dropbox

    def perform(user, app)
      Dropbox::PushService.new(user, app).execute
    end
  end
end
