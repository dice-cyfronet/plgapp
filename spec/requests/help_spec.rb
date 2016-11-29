require 'rails_helper'

RSpec.describe 'help pages' do
  let(:user) { create(:user) }
  before { login_as(user) }

  it 'chooses help for selected locale' do
    get help_path

    expect(response.body).to include('supports development mode')
  end
end
