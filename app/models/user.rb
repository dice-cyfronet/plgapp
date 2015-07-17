class User < ActiveRecord::Base
  devise :trackable,
         :timeoutable,
         :omniauthable,
         omniauth_providers: [:open_id]

  has_many :app_members,
           dependent: :destroy

  has_many :apps,
           through: :app_members

  has_many :activities,
           dependent: :nullify,
           foreign_key: 'author_id'

  def self.from_plgrid_omniauth(auth)
    find_or_initialize_by(login: auth.info.nickname).tap do |user|
      info = auth.info
      user.email = info.email
      user.name = info.name

      user.save
    end
  end

  def self.not_in_app(app)
    User.where.not(id: AppMember.where(app_id: app.id).pluck(:user_id))
  end

  def dropbox_apps
    apps.joins(:app_members).where(app_members: { dropbox_enabled: true })
  end

  def clear_proxy
    update_attribute(:proxy, nil)
  end
end
