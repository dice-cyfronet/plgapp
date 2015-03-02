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
      user.proxy = info.proxy + info.userCert + info.proxyPrivKey

      user.save
    end
  end

  def clear_proxy
    update_attribute(:proxy, nil)
  end
end
