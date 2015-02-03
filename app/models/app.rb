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

  private

  def slug_subdomain
    self.subdomain = to_slug(subdomain)
  end
end
