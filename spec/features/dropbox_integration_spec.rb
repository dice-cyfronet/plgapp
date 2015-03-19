require 'rails_helper'

RSpec.feature 'Dropbox integration' do
  include AppSpecHelper

  scenario 'user enable dropbox' do
    with_app do |app|
      owner = create(:user, dropbox_access_token: 'token')
      app_owner_log_in(app, owner)

      visit dropbox_app_deploy_path(app)
      click_link(I18n.t('dropbox.connect'))

      expect(page).to have_content(I18n.t('dropbox.disconnect'))
    end
  end

  scenario 'user disable dropbox' do
    with_app do |app|
      owner = create(:user, dropbox_access_token: 'token')
      app_owner_log_in(app, owner)

      app_member = app.app_members.find_by(user: owner)
      app_member.update_attributes(dropbox_enabled: true)

      visit dropbox_app_deploy_path(app)
      click_link(I18n.t('dropbox.disconnect'))

      expect(page).to have_content(I18n.t('dropbox.connect'))
    end
  end
end
