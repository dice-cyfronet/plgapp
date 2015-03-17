class UpdateUserAppsFromDropboxJob < ActiveJob::Base
  queue_as :dropbox

  def perform(dropbox_user_id)
    Rails.logger.info("TODO: update user apps: #{dropbox_user_id}")
  end
end
