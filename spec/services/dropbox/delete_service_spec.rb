require 'rails_helper'

RSpec.describe Dropbox::DeleteService do
  include DropboxHelper

  let(:author) { create(:user) }
  let(:client) { instance_double('DropboxClient') }

  before { allow(client).to receive(:file_delete) }

  it 'removes dropbox app directory' do
    expect_delete

    service.execute
  end

  context 'application exist' do
    let(:app) do
      create(:app, users: [author], subdomain: 'subdomain-to-delete')
    end
    let(:app_member) { app.app_members.find_by(user: author) }

    it 'removes all dropbox exntries when app exist' do
      dir_entries('dir1', 'dir1/subdir')
      file_entry('file.txt')

      service.execute

      expect(app_member.dropbox_entries.count).to eq 0
    end
  end

  it 'clean dropbox account when no dropbox app present for the user' do
    author.update_attributes(dropbox_access_token: 'token', dropbox_user: '123')

    service.execute
    author.reload

    expect(author.dropbox_access_token).to be_nil
    expect(author.dropbox_user).to be_nil
  end

  def expect_delete
    expect(client).
      to receive(:file_delete).
      with('/subdomain-to-delete')
  end

  def service
    described_class.new(author, 'subdomain-to-delete', client: client)
  end
end
