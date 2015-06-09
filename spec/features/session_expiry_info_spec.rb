require 'rails_helper'

RSpec.feature 'Session expiry info' do
  scenario 'supply expiry information' do
    visit root_path

    expiry_cookie = get_me_the_cookie('session_expiry')
    expect(expiry_cookie).not_to be_nil
    expect(expiry_cookie[:value]).to match(/[0-9\.]/)
  end
end
