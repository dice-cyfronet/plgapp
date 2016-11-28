class DropboxEntry < ApplicationRecord
  belongs_to :app_member,
             required: true

  validates :path, presence: true
end
