class CreateDropboxEntries < ActiveRecord::Migration
  def change
    create_table :dropbox_entries do |t|
      t.string :path, null: false
      t.boolean :is_dir, default: false
      t.string :local_hash
      t.string :remote_hash
      t.string :revision

      t.references :app_member, null: false

      t.timestamps null: false
    end

    add_foreign_key :dropbox_entries, :app_members, index: true
    add_index :dropbox_entries, :path
  end
end
