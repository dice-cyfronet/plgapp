class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable,
         :omniauthable,
         omniauth_providers: [:open_id]

  has_many :apps,
           foreign_key: 'author_id'

  def self.from_plgrid_omniauth(auth)
    find_or_initialize_by(login: auth.info.nickname).tap do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.save
    end
  end
end
