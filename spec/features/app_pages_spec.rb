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

  scenario 'serves development files' do
    custom_app = create(:app, subdomain: 'dummy')
    in_subdomain(custom_app.dev_subdomain) do
      user = create(:user, apps: [custom_app])
      login_as(user, scope: :user)

      visit root_path

      expect(page).to have_content 'devel index page'
    end
  end

  scenario 'all logged used are able to see production files' do
    custom_app = create(:app, subdomain: 'dummy')
    in_subdomain(custom_app.full_subdomain) do
      user = create(:user)
      login_as(user, scope: :user)

      visit root_path

      expect(page.status_code).to eq 200
    end
  end

  scenario 'only app developer is able to see dev files' do
    custom_app = create(:app, subdomain: 'dummy')
    in_subdomain(custom_app.dev_subdomain) do
      user = create(:user)
      login_as(user, scope: :user)

      visit root_path

      expect(page.status_code).to eq 403
    end
  end
end
