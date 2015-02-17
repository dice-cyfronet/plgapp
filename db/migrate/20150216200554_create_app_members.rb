class CreateAppMembers < ActiveRecord::Migration
  def change
    create_table :app_members do |t|
      t.belongs_to :app,  null: false
      t.belongs_to :user, null: false

      t.timestamps null: false
    end

    add_index :app_members, [:app_id, :user_id], unique: true
    add_foreign_key :app_members, :users
    add_foreign_key :app_members, :apps
  end
end
