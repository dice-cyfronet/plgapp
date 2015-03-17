require 'rails_helper'

RSpec.describe Dropbox::PullService do
  include AppSpecHelper
  include AppFilesHelper
  include DropboxHelper

  let(:author) { create(:user) }
  let(:app) { create(:app, users: [author]) }
  let(:client) { instance_double('DropboxClient') }
  let(:app_member) { app.app_members.find_by(user: author) }

  before do
    CreateAppService.new(author, app).execute
    app_member.update_attributes(dropbox_cursor: 'cursor')
  end
  after  { DestroyAppService.new(app).execute }

  it 'delete files' do
    create_dev_file(app, 'file1.txt', 'foo')
    create_dev_file(app, 'sub/file2.txt', 'bar')

    file_entry('file1.txt')
    dir_entries('sub')
    file_entry('sub/file2.txt')

    expect_delta(
        ["/#{app.subdomain}/file1.txt", nil],
        ["/#{app.subdomain}/sub/file2.txt", nil],
        ["/#{app.subdomain}/sub", nil],
        ["/#{app.subdomain}/not_existing.txt", nil]
    )

    service.execute

    expect(File.exist?(path('file1.txt'))).to be_falsy
    expect(File.exist?(path('sub'))).to be_falsy
    expect(app_member.dropbox_entries.count).to eq 0
  end

  it 'creates new files' do
    expect_delta(
      [
        "/#{app.subdomain}/file1.txt",
        {
          'rev' => '1',
          'path' => "/#{app.subdomain}/file1.txt",
          'is_dir' => false,
          'revision' => 24
        }
      ], [
        "/#{app.subdomain}/sub/file2.txt",
        {
          'rev' => '2',
          'path' => "/#{app.subdomain}/sub/file2.txt",
          'is_dir' => false
        }
      ], [
        "/#{app.subdomain}/sub",
        {
          'rev' => '3',
          'path' => "/#{app.subdomain}/sub",
          'is_dir' => true
        }
      ]
    )
    expect_get_file("/#{app.subdomain}/file1.txt", 'foo')
    expect_get_file("/#{app.subdomain}/sub/file2.txt", 'bar')

    service.execute
    file2 = entry('sub/file2.txt')
    sub = entry('sub')

    expect(File.read(path('file1.txt'))).to eq 'foo'
    expect(File.read(path('sub/file2.txt'))).to eq 'bar'
    expect(File.directory?(path('sub'))).to be_truthy

    expect(app_member.dropbox_entries.count).to eq 3
    expect(file2.is_dir).to be_falsy
    expect(file2.revision).to eq '2'
    expect(file2.path).to eq 'sub/file2.txt'

    expect(sub.is_dir).to be_truthy
    expect(sub.revision).to eq '3'
    expect(sub.path).to eq 'sub'
  end

  it 'updates files' do
    create_dev_file(app, 'file1.txt', 'foo')
    create_dev_dir(app, 'sub')
    file_entry('file1.txt')
    file_entry('not_modified', 12)
    dir_entries('sub')

    expect_delta(
      [
        "/#{app.subdomain}/file1.txt",
        {
          'rev' => '6',
          'path' => "/#{app.subdomain}/file1.txt",
          'is_dir' => false,
          'revision' => 24
        }
      ], [
        "/#{app.subdomain}/sub",
        {
          'rev' => '7',
          'path' => "/#{app.subdomain}/sub",
          'is_dir' => true
        }
      ], [
        "/#{app.subdomain}/not_modified",
        {
          'rev' => '12',
          'path' => "/#{app.subdomain}/not_modified",
          'is_dir' => false
        }
      ]
    )
    expect_get_file("/#{app.subdomain}/file1.txt", 'bar')
    expect(client).
      to_not receive(:get_file).
      with("/#{app.subdomain}/not_modified")

    service.execute
    file1 = entry('file1.txt')
    sub = entry('sub')

    expect(File.read(path('file1.txt'))).to eq 'bar'
    expect(file1.revision).to eq '6'
    expect(sub.revision).to eq '7'
  end

  def expect_delta(*entries)
    expect(client).
      to receive(:delta).
      with('cursor', "/#{app.subdomain}").
      and_return(
        'has_more' => false,
        'cursor' => 'new_cursor',
        'reset' => false,
        'entries' => entries
      )
  end

  def expect_get_file(path, content, revision = nil)
    expect(client).
      to receive(:get_file).
      with(path).
      and_return(content)
  end

  def path(path)
    app_file_path(app.dev_subdomain, path)
  end

  def service
    described_class.new(author, app, client: client)
  end
end