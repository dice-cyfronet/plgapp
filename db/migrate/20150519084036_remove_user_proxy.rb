class RemoveUserProxy < ActiveRecord::Migration
  def change
    remove_column :users, :proxy
  end
end
