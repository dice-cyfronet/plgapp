class AddAppMemberRole < ActiveRecord::Migration
  def up
    # default role is :developer
    add_column :app_members, :role, :integer, default: 1, null: false
    # Set manager roles to all existing app members
    execute('UPDATE app_members SET role = 0 WHERE 1=1')
  end

  def down
    remove_column :app_member, :role
  end
end
