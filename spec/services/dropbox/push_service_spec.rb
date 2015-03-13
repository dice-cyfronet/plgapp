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
    dir_entries('.')

    expect(client).to_not receive(:file_create_folder)

    expect { service.execute }.to change { DropboxEntry.count }.by 0
  end

  it 'creates new files in dropbox' do
    dir_entries('.')
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

    expect(file1.local_hash).to eq 'acbd18db4cc2f85cedef654fccc4a4d8'
    expect(file1.revision).to eq "1"
  end

  it 'updates files in dropbox' do
    dir_entries('.', 'sub')
    file_entry('file1', '1', 'acbd18db4cc2f85cedef654fccc4a4d8')
    file_entry('sub/file2', '1', 'acbd18db4cc2f85cedef654fccc4a4d8')

    create_dev_file(app, 'file1', 'foo')
    create_dev_file(app, 'sub/file2', 'bar')

    expect_file('sub/file2', '1')

    service.execute
    file2 = entry('sub/file2')

    expect(file2.revision).to eq '2'
    expect(file2.local_hash).to eq '37b51d194a7513e45b56f6524f2d51f2'
  end

  it 'deletes files from dropbox' do
    dir_entries('.', 'sub')
    file_entry('file1', '1', 'acbd18db4cc2f85cedef654fccc4a4d8')
    file_entry('sub/file2', '1', 'acbd18db4cc2f85cedef654fccc4a4d8')

    expect_delete('file1')
    expect_delete('sub')
    expect_delete('sub/file2')

    service.execute
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
      with("/#{app.subdomain}/#{path}", instance_of(File), false, revision).
      and_return('rev' => revision && Integer(revision) + 1 || 1)
  end

  def expect_delete(path)
    expect(client).
      to receive(:file_delete).
      with("/#{app.subdomain}/#{path}")
  end

  def service
    described_class.new(author, app, client: client)
  end

  def dir_entries(*paths)
    paths.each do |path|
      app_member.dropbox_entries.create!(path: path, is_dir: true)
    end
  end

  def file_entry(path, revision, hash)
    app_member.dropbox_entries.
      create!(path: path, is_dir: false, revision: revision, local_hash: hash)
  end
end
