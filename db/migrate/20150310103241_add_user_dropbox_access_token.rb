class AddUserDropboxAccessToken < ActiveRecord::Migration
  def change
    add_column :users, :dropbox_access_token, :string
  end
end
