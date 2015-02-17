class AppMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :app

  validates :user, presence: true
  validates :app, presence: true

  validates :user_id,
            uniqueness: {
              scope: :app_id,
              message: I18n.t('apps.already_a_member')
            }
end
