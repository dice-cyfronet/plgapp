require 'rails_helper'

RSpec.feature 'App activities' do
  include AppSpecHelper

  scenario 'list app activities' do
    with_app do |app|
      user = create(:user)
      UpdateAppService.new(user, app, name: 'new name').execute
      PushToProductionService.new(user, app, message: 'push message').execute

      app_owner_log_in(app)
      visit activity_app_path(app)

      expect(page).to have_content('Created application')
      expect(page).to have_content('Updated application')

      expect(page).to have_content('Deployment')
      expect(page).to have_content('push message')
    end
  end
end
