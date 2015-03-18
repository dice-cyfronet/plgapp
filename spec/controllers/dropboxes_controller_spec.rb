require 'rails_helper'

RSpec.describe DropboxesController do
  it 'verify dropbox webhook' do
    get :webhook_verify, challenge: '123'

    expect(response).to be_ok
    expect(response.body).to eq '123'
  end

  context 'dropbox delta' do
    before do
      @old_app_key = Rails.configuration.dropbox.app_key
      Rails.configuration.dropbox.app_secret = 'app_secret'
    end
    after { Rails.configuration.dropbox.app_key = @old_app_key }

    it 'triggers dropbox update' do
      service = instance_double('Dropbox::UpdateUsersAppsServoce')

      expect(Dropbox::UpdateUsersAppsService).
        to receive(:new).with(['1', '2']).and_return(service)
      expect(service).to receive(:execute)

      request.headers['X-Dropbox-Signature'] =
        'aae047deeec6f5347e5dd7f94a2b408196979a56fd7962b971a99849d2132aa0'
      post :delta, delta: { users: ['1', '2'] }

      expect(response).to be_ok
    end

    it 'dont allow to update users when dropbox signature is not valid' do
      post :delta, delta: { users: ['1', '2'] }

      expect(response).to be_unauthorized
    end
  end
end
