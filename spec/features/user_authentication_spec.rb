require 'rails_helper'

RSpec.feature 'User authentication' do
  include OauthHelper
  include AuthenticationHelper

  scenario 'user signs in' do
    user = create(:user)

    sign_in_as(user)

    expect(page).to have_content user.name
  end

  scenario 'user signs out' do
    user = create(:user)

    sign_in_as(user)
    find(:linkhref, '/sign_out').click

    expect(page).not_to have_content user.name
  end
end
