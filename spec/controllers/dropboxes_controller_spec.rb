require 'rails_helper'

RSpec.describe DropboxesController do
  it 'verify dropbox webhook' do
    get :webhook_verify, challenge: '123'

    expect(response).to be_ok
    expect(response.body).to eq '123'
  end

  it 'triggers dropbox update' do
    expect(UpdateUserAppsFromDropboxJob).to receive(:perform_later).with('1')
    expect(UpdateUserAppsFromDropboxJob).to receive(:perform_later).with('2')

    post :delta, delta: { users: ['1', '2'] }

    expect(response).to be_ok
  end
end
