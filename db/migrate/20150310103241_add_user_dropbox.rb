class AddUserDropbox < ActiveRecord::Migration
  def change
    add_column :users, :dropbox_user, :string
    add_column :users, :dropbox_access_token, :string
  end
end
