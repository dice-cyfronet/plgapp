require 'rails_helper'

RSpec.feature 'Login page' do
  scenario 'with default text for main app' do
    visit root_path

    expect(page).to have_content 'Some introduction'
  end

  scenario 'with custom text for user app' do
    custom_app = create(:app, login_text: 'custom app')

    in_subdomain(custom_app.full_subdomain) do
      visit root_path

      expect(page).to have_content('custom app')
    end
  end
end
