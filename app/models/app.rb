class App < ActiveRecord::Base
  validates :name, presence: true

  validates :subdomain,
            presence: true,
            uniqueness: { case_sensitive: false }
end
