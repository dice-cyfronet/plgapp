class AppMember < ActiveRecord::Base
  enum role: [:master, :developer, :reporter]

  belongs_to :user
  belongs_to :app

  has_many :dropbox_entries, dependent: :destroy


  validates :user, presence: true
  validates :app, presence: true
  validates :role, presence: true

  validates :user_id,
            uniqueness: {
              scope: :app_id,
              message: I18n.t('apps.already_a_member')
            }

  before_validation :set_default_user_role, if: :new_record?

  def dropbox_enabled?
    dropbox_enabled
  end

  private

  def set_default_user_role
    self.role ||= default_user_role
  end

  def default_user_role
    members_count == 0 ? :master : :developer
  end

  def members_count
    AppMember.where(app_id: app_id).count
  end
end
