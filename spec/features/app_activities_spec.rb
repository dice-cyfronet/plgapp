require 'rails_helper'

RSpec.feature 'App activities' do
  include AppSpecHelper

  scenario 'list app activities' do
    with_app do |app|
      UpdateAppService.new(create(:user), app, name: 'new name').execute

      app_owner_log_in(app)
      visit activity_app_path(app)

      expect(page).to have_content('Created application')
      expect(page).to have_content('Updated application')
    end
  end
end
