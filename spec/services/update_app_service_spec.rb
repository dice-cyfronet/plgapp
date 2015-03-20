require 'rails_helper'

RSpec.describe UpdateAppService do
  include AppSpecHelper

  let(:author) { create(:user) }
  let(:app) { build(:app) }

  before { CreateAppService.new(author, app).execute }
  after { DestroyAppService.new(app).execute }

  it 'updates app attributes' do
    params = { name: 'New name' }
    subject = UpdateAppService.new(author, app, params)

    subject.execute

    expect(app.name).to eq 'New name'
  end

  it 'rename app dir when subdomain changed' do
    params = { subdomain: 'new_subdomain' }
    subject = UpdateAppService.new(author, app, params)
    old_app_dir = app_dir(app)
    old_app_dev_dir = app_dev_dir(app)

    subject.execute

    expect(old_app_dir.exist?).to be_falsy
    expect(app_dir(app).exist?).to be_truthy

    expect(old_app_dev_dir.exist?).to be_falsy
    expect(app_dev_dir(app).exist?).to be_truthy
  end

  it 'rename dropbox dir when subdomain changed' do
    params = { subdomain: 'new_subdomain' }
    subject = UpdateAppService.new(author, app, params)
    app.app_members.create(user: author, dropbox_enabled: true)

    expect(Dropbox::MoveService).
      to receive(:new).
      with(author, app).
      and_return(double(execute: true))

    subject.execute
  end

  it 'does not rename app dir when update failed' do
    params = { subdomain: 'new_subdomain', name: nil }
    subject = UpdateAppService.new(author, app, params)
    old_app_dir = app_dir(app)
    old_app_dev_dir = app_dev_dir(app)
    new_app_dir = app_dir('new_subdomain')
    new_app_dev_dir = app_dev_dir('new_subdomain')

    status = subject.execute

    expect(status).to be_falsy
    expect(old_app_dir.exist?).to be_truthy
    expect(new_app_dir.exist?).to be_falsy

    expect(old_app_dev_dir.exist?).to be_truthy
    expect(new_app_dev_dir.exist?).to be_falsy

    # ensure to remove correct dir when leaving with_app
    app.reload
  end

  it 'creates activity log for update' do
    params = { name: 'New name' }
    subject = UpdateAppService.new(author, app, params)

    expect { subject.execute }.to change { Activity.count }.by 1
    activity = app.activities.last

    expect(activity.activity_type).to eq 'updated'
    expect(activity.author).to eq author
  end

  it 'triggerd dropbox update' do
    # something which will do the change
    params = { login_text: 'asdf' }
    subject = UpdateAppService.new(author, app, params)
    # turn on dropbox
    app.app_members.create(user: author, dropbox_enabled: true)

    # simulate zip upload
    allow(app).to receive(:content_changed?).and_return(true)

    expect(Dropbox::PushJob).
      to receive(:perform_later).with(author, app)

    subject.execute
  end
end
