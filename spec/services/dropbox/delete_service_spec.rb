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

    it 'cleans dropbox cursor' do
      app_member.update_attributes(dropbox_cursor: 'cursor')

      service.execute
      app_member.reload

      expect(app_member.dropbox_cursor).to be_nil
    end
  end

  it 'clean dropbox account when no dropbox app present for the user' do
    author.update_attributes(dropbox_access_token: 'token', dropbox_user: '123')

    service.execute
    author.reload

    expect(author.dropbox_access_token).to be_nil
    expect(author.dropbox_user).to be_nil
  end

  it 'does not clean dropbox account when other dropbox app exist' do
    author.update_attributes(dropbox_access_token: 'token', dropbox_user: '123')
    other_app = create(:app, users: [author], subdomain: 'other-app')
    other_app_member = other_app.app_members.find_by(user: author)

    other_app_member.update_attributes(dropbox_enabled: true)

    service.execute
    author.reload

    expect(author.dropbox_access_token).to_not be_nil
    expect(author.dropbox_user).to_not be_nil
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
