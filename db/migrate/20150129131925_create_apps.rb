class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name,      null: false, default: ''
      t.string :subdomain, null: false
      t.text   :login_text

      t.belongs_to :author, index: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :apps, :users, column: :author_id
    add_index :apps, :subdomain, unique: true
  end
end
