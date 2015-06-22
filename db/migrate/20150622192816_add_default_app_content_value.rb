class AddDefaultAppContentValue < ActiveRecord::Migration
  def up
    change_column :apps, :content, :string, default: 'content'
  end

  def down
    change_column :apps, :content, :string, default: nil
  end
end
