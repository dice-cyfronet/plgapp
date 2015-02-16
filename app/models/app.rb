class App < ActiveRecord::Base
  include Slugable

  validates :name, presence: true

  validates :subdomain,
            presence: true,
            uniqueness: { case_sensitive: false }

  belongs_to :author,
             class_name: 'User',
             foreign_key: 'author_id',
             required: true

  before_save :slug_subdomain

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
