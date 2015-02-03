class User < ActiveRecord::Base
  devise :trackable,
         :omniauthable,
         omniauth_providers: [:open_id]

  has_many :apps,
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
end
