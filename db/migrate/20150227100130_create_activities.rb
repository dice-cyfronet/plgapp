class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :activity_type, default: 0
      t.datetime :created_at, null: false

      t.references :app, null: false
      t.references :author, null: false
    end

    add_foreign_key :activities, :users, column: :author_id
    add_index :activities, :author_id

    add_foreign_key :activities, :apps
    add_index :activities, :app_id
  end
end
