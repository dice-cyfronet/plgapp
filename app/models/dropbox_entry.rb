class DropboxEntry < ActiveRecord::Base
  belongs_to :app_member,
             required: true

  belongs_to :parent,
             class_name: 'DropboxEntry',
             foreign_key: 'parent_id'

  has_many :children,
           class_name: 'DropboxEntry',
           foreign_key: 'parent_id'

  validates :path, presence: true
end
