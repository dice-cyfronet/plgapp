class Activity < ApplicationRecord
  enum activity_type: [:deployment, :created, :updated]

  belongs_to :app,
             required: true

  belongs_to :author,
             class_name: 'User',
             foreign_key: 'author_id',
             required: true
end
