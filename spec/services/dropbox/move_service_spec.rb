require 'rails_helper'

RSpec.describe Dropbox::MoveService do
  include DropboxHelper

  let(:author) { create(:user) }
  let(:app) { create(:app, subdomain: 'from') }
  let(:client) { instance_double('DropboxClient') }

  context 'subdomain changed' do
    it 'rename app dropbox directory' do
      expect(client).to receive(:file_move).with('from', 'to')

      app.update_attributes(subdomain: 'to')
      service.execute
    end
  end

  context 'subdomain not changed' do
    it 'dont rename app dropbox directory' do
      app.update_attributes(name: 'other name')
      service.execute
    end
  end

  def service
    described_class.new(author, app, client: client)
  end
end
