class AddAppMemberDropbox < ActiveRecord::Migration
  def change
    add_column :app_members, :dropbox_enabled, :boolean, default: false
    add_column :app_members, :dropbox_cursor, :string
  end
end
