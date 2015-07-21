module Dropbox
  class DisableJob < ActiveJob::Base
    queue_as :dropbox

    def perform(user)
      Dropbox::DisableService.new(user).execute
    end
  end
end
