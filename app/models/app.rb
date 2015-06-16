require 'file_size_validator'

class App < ActiveRecord::Base
  include Slugable

  extend FriendlyId
  friendly_id :subdomain

  mount_uploader :content, AppUploader
  mount_uploader :logo, LogoUploader

  has_many :app_members,
           dependent: :destroy,
           autosave: true

  has_many :users,
           through: :app_members

  has_many :activities,
           dependent: :destroy,
           autosave: true

  validates :name, presence: true

  validates :subdomain,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :logo, file_size: { maximum: 0.5.megabytes.to_i }

  validate :not_a_devel_subdomain

  before_validation :slug_subdomain

  before_save :set_old_subdomain

  def deploy?
    content_changed?
  end

  def update?
    name_changed? || subdomain_changed? || login_text_changed?
  end

  def dev_subdomain
    "#{subdomain}#{Rails.configuration.dev_postfix}"
  end

  def full_subdomain
    "#{subdomain}#{subdomain_postfix}"
  end

  def dev_full_subdomain
    "#{dev_subdomain}#{subdomain_postfix}"
  end

  attr_reader :old_subdomain

  private

  def not_a_devel_subdomain
    dev_postfix = Rails.configuration.dev_postfix
    if subdomain && subdomain.end_with?(dev_postfix)
      errors.add(:subdomain, I18n.t('apps.without_dev', postfix: dev_postfix))
    end
  end

  def subdomain_postfix
    domain_prefix = Rails.configuration.constants['domain_prefix']
    domain_prefix ? ".#{domain_prefix}" : ''
  end

  def slug_subdomain
    self.subdomain = to_slug(subdomain) if subdomain
  end

  def set_old_subdomain
    @old_subdomain = subdomain_was
  end
end
