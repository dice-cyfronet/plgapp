require 'rails_helper'

RSpec.feature 'Main page apps' do
  scenario 'are shown only when selected' do
    create(:app, name: 'selected1', show_on_main_page: true)
    create(:app, name: 'not selected')
    create(:app, name: 'selected2', show_on_main_page: true)

    visit root_path

    expect(page).to have_content('selected1')
    expect(page).to have_content('selected2')
    expect(page).to_not have_content('not selected')
  end
end
