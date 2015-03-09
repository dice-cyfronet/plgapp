require 'rails_helper'

RSpec.feature 'App info' do
  include OauthHelper
  include AuthenticationHelper
  include Warden::Test::Helpers

  scenario 'returns info in production mode' do
    logged_in_subdomain('dummy') do |user|
      visit info_path

      expect(json_response['userLogin']).to eq user.login
      expect(json_response['csrfToken']).to_not be_nil
      expect(json_response['development']).to be_falsy
    end
  end

  scenario 'returns info in development mode' do
    logged_in_subdomain('dummy', dev: true) do
      visit info_path

      expect(json_response['development']).to be_truthy
    end
  end

  def json_response
    JSON.parse(page.body)
  end
end
