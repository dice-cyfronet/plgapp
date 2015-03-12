class AppMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :app

  has_many :dropbox_entries, dependent: :destroy

  validates :user, presence: true
  validates :app, presence: true

  validates :user_id,
            uniqueness: {
              scope: :app_id,
              message: I18n.t('apps.already_a_member')
            }

  def dropbox_enabled?
    dropbox_enabled
  end
end
