class AddAppMemberDropboxEnabled < ActiveRecord::Migration
  def change
    add_column :app_members, :dropbox_enabled, :boolean, default: false
  end
end
