require 'rails_helper'

RSpec.feature 'Apps' do
  include OauthHelper
  include AuthenticationHelper
  include FormHelper

  scenario 'are shown on root page only when selected' do
    create(:app, name: 'selected1', show_on_main_page: true)
    create(:app, name: 'not selected')
    create(:app, name: 'selected2', show_on_main_page: true)

    visit root_path

    expect(page).to have_content('selected1')
    expect(page).to have_content('selected2')
    expect(page).to_not have_content('not selected')
  end

  scenario 'title not shown when no apps' do
    create(:app, name: 'not selected')

    visit root_path

    expect(page).to_not have_content(I18n.t('home.apps-title'))
  end

  context 'admin' do
    before { sign_in_as_admin }

    scenario 'admin sees apps selection tab' do
      expect(page).to have_xpath("//a[@href='#{admin_apps_path}']")
    end

    scenario 'admin sees apps selection view' do
      selected = create(:app, name: 'selected', show_on_main_page: true)
      unselected = create(:app, name: 'unselected')

      visit admin_apps_path

      expect(page).to have_xpath(i_xpatch(admin_app_path(selected), 'globe'))
      expect(page).to have_xpath(i_xpatch(admin_app_path(unselected), 'shield'))
    end

    scenario 'update apps selection for main page' do
      app = create(:app, name: 'unselected')

      visit admin_app_path(app)
      check(I18n.t('simple_form.labels.app.show_on_main_page'))
      submit_form

      expect(page).to have_xpath(i_xpatch(admin_app_path(app), 'globe'))
    end

    def i_xpatch(path, fa_icon_name)
      "//a[@href='#{path}']/h5/i[@class='fa fa-#{fa_icon_name}']"
    end
  end
end
