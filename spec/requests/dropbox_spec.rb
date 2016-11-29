require 'rails_helper'

RSpec.describe 'dropbox' do
  it 'verify dropbox webhook' do
    get dropbox_webhook_path, params: { challenge: '123' }

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

      post dropbox_delta_path,
           params: { delta: { users: ['1', '2'] } },
           headers: { 'X-Dropbox-Signature' =>
                      'a458d3e23d3f23982b0eac2e6a4d151db978649d75145f827b99e0238c20144c' }

      expect(response).to be_ok
    end

    it 'dont allow to update users when dropbox signature is not valid' do
      post dropbox_delta_path, params: { delta: { users: ['1', '2'] } }

      expect(response).to be_unauthorized
    end
  end
end
