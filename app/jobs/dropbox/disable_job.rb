module Dropbox
  class DisableJob < ApplicationJob
    queue_as :dropbox

    def perform(user)
      Dropbox::DisableService.new(user).execute
    end
  end
end
