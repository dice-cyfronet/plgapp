class App < ActiveRecord::Base
  include Slugable

  extend FriendlyId
  friendly_id :subdomain

  mount_uploader :content, AppUploader

  has_many :app_members,
           dependent: :destroy

  has_many :users,
           through: :app_members

  has_many :activities,
           dependent: :destroy,
           autosave: true

  validates :name, presence: true

  validates :subdomain,
            presence: true,
            uniqueness: { case_sensitive: false }

  before_save :slug_subdomain

  def deploy?
    content_changed?
  end

  def update?
    name_changed? || subdomain_changed? || login_text_changed?
  end

  def full_subdomain
    "#{subdomain}#{subdomain_postfix}"
  end

  private

  def subdomain_postfix
    domain_prefix = Rails.configuration.constants['domain_prefix']
    domain_prefix ? ".#{domain_prefix}" : ''
  end

  def slug_subdomain
    self.subdomain = to_slug(subdomain)
  end
end
