require 'rails_helper'

RSpec.feature 'App pages' do
  include OauthHelper
  include AuthenticationHelper
  include Warden::Test::Helpers

  scenario 'returns info about CSRF token' do
    logged_in_subdomain('dummy') do
      visit csrf_token_path

      expect(json_response['csrfToken']).to_not be_nil
    end
  end

  def json_response
    JSON.parse(page.body)
  end
end
