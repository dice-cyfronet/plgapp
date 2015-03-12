require 'rails_helper'

RSpec.describe Dropbox::PushService do
  include AppSpecHelper
  include AppFilesHelper

  let(:author) { create(:user) }
  let(:app) { build(:app, users: [author]) }
  let(:client) { instance_double('DropboxClient') }
  let(:app_member) { app.app_members.find_by(user: author) }

  before { CreateAppService.new(author, app).execute }
  after  { DestroyAppService.new(app).execute }

  it 'creates app dir in dropbox' do
    expect(client).to receive(:file_create_folder).with("/#{app.subdomain}")

    expect { service.execute }.to change { DropboxEntry.count }.by 1
    entry = DropboxEntry.last

    expect(entry.path).to eq '.'
    expect(entry.is_dir).to be_truthy
  end

  it 'does not create app dir in dropbox when already created' do
    app_member.dropbox_entries.create!(path: '.', is_dir: true)

    expect(client).to_not receive(:file_create_folder)

    expect { service.execute }.to change { DropboxEntry.count }.by 0
  end

  it 'creates new files in dropbox' do
    app_member.dropbox_entries.create!(path: '.', is_dir: true)
    create_dev_file(app, 'file1.txt', 'foo')
    create_dev_file(app, 'sub/file2.txt', 'bar')
    create_dev_dir(app, 'sub/dir')

    expect_dir('sub')
    expect_dir('sub/dir')
    expect_file('file1.txt')
    expect_file('sub/file2.txt')

    service.execute
    sub_entry = entry('sub')
    subdir_entry = entry('sub/dir')
    file1 = entry('file1.txt')
    file2 = entry('sub/file2.txt')

    expect(sub_entry.is_dir).to be_truthy
    expect(subdir_entry.is_dir).to be_truthy
  end

  it 'updates files in dropbox' do

  end

  it 'deletes files from dropbox' do

  end

  def entry(path)
    app_member.dropbox_entries.find_by!(path: path)
  end

  def expect_dir(path)
    expect(client).
      to receive(:file_create_folder).
      with("/#{app.subdomain}/#{path}")
  end

  def expect_file(path, revision = nil)
    expect(client).
      to receive(:put_file).
      with("/#{app.subdomain}/#{path}", instance_of(File), false, nil)
  end

  def service
    described_class.new(author, app, client: client)
  end
end
