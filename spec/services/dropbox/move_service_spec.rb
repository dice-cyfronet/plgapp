require 'rails_helper'

RSpec.describe Dropbox::MoveService do
  include DropboxHelper

  let(:author) { create(:user) }
  let(:client) { instance_double('DropboxClient') }

  context 'subdomain changed' do
    it 'rename app dropbox directory' do
      service = described_class.new(author, 'from', 'to', client: client)

      expect(client).to receive(:file_move).with('from', 'to')

      service.execute
    end
  end

  context 'subdomain not changed' do
    it 'dont rename app dropbox directory' do
      service = described_class.new(author, 'from', 'from', client: client)

      expect(client).to_not receive(:file_move)

      service.execute
    end
  end
end
