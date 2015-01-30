class App < ActiveRecord::Base
  include Slugable

  validates :name, presence: true

  validates :subdomain,
            presence: true,
            uniqueness: { case_sensitive: false }

  before_save :slug_subdomain

  private

  def slug_subdomain
    self.subdomain = to_slug(subdomain)
  end
end
