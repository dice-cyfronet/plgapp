class AddAppShowOnMainPage < ActiveRecord::Migration
  def change
    add_column :apps, :show_on_main_page, :boolean, default: false
  end
end
