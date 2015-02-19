require 'rails_helper'

RSpec.feature 'Application locales' do
  scenario 'support pl locales' do
    visit root_path(locale: :pl)

    expect(page).to have_content 'Zaloguj się przez PL-Grid'
  end

  scenario 'support en locales' do
    visit root_path(locale: :en)

    expect(page).to have_content 'PL-Grid login'
  end
end