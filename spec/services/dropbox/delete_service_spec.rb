require 'rails_helper'

RSpec.describe Dropbox::DeleteService do
  include DropboxHelper

  let(:author) { create(:user) }
  let(:client) { instance_double('DropboxClient') }

  before { allow(client).to receive(:file_move) }

  it 'removes dropbox app directory' do
    allow(Time).to receive(:now).
      and_return(Time.utc(2015, 6, 17, 13, 3, 23))
    expect(client).
      to receive(:file_move).
      with('subdomain-to-delete',
           'subdomain-to-delete (detached at 2015-06-17 13:03:23 UTC)')

    service.execute
  end

  context 'application exist' do
    let(:app) do
      create(:app, users: [author], subdomain: 'subdomain-to-delete')
    end
    let!(:app_member) do
      app.app_members.find_by(user: author).tap do |app_member|
        app_member.update_attributes(dropbox_enabled: true)
      end
    end

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

    it 'clean dropbox account when no other dropbox apps present for the user' do
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
  end

  def service
    described_class.new(author, 'subdomain-to-delete', client: client)
  end
end
