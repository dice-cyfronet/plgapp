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

  scenario 'user has proxy' do
    user = create(:user)

    sign_in_as(user)
    user.reload

    expect(user.proxy).to_not be_nil
  end

  scenario 'user proxy is cleared after signs out' do
    user = create(:user)

    sign_in_as(user)
    find(:linkhref, '/sign_out').click
    user.reload

    expect(user.proxy).to be_nil
  end
end
