class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name,      null: false, default: ''
      t.string :subdomain, null: false

      t.timestamps null: false
    end

    add_index :apps, :subdomain, unique: true
  end
end
