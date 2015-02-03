require 'rails_helper'

RSpec.feature 'App pages' do
  include OauthHelper
  include AuthenticationHelper
  include Warden::Test::Helpers

  scenario 'serves index on root path' do
    logged_in_subdomain('dummy') do

      visit root_path

      expect(page).to have_content 'index page'
    end
  end

  scenario 'serves different pages' do
    logged_in_subdomain('dummy') do
      visit '/other.html'

      expect(page).to have_content 'other page'
    end
  end
end
