module Dropbox
  class MoveJob < ActiveJob::Base
    queue_as :dropbox

    def perform(user, from, to)
      Dropbox::MoveService.new(user, from, to).execute
    end
  end
end
