module Dropbox
  class MoveJob < ApplicationJob
    queue_as :dropbox

    def perform(user, from, to)
      Dropbox::MoveService.new(user, from, to).execute
    end
  end
end
