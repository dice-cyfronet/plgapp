require 'rails_helper'

RSpec.describe UpdateAppService do
  include AppSpecHelper

  let(:author) { create(:user) }
  let(:app) { build(:app) }

  before { CreateAppService.new(author, app).execute }

  it 'updates app attributes' do
    params = { name: 'New name' }
    subject = UpdateAppService.new(author, app, params)

    with_app(app) do
      subject.execute

      expect(app.name).to eq 'New name'
    end
  end

  it 'rename app dir when subdomain changed' do
    params = { subdomain: 'new_subdomain' }
    subject = UpdateAppService.new(author, app, params)
    old_app_dir = app_dir(app)
    old_app_dev_dir = app_dev_dir(app)

    with_app(app) do
      subject.execute

      expect(old_app_dir.exist?).to be_falsy
      expect(app_dir(app).exist?).to be_truthy

      expect(old_app_dev_dir.exist?).to be_falsy
      expect(app_dev_dir(app).exist?).to be_truthy
    end
  end

  it 'does not rename app dir when update failed' do
    params = { subdomain: 'new_subdomain', name: nil }
    subject = UpdateAppService.new(author, app, params)
    old_app_dir = app_dir(app)
    old_app_dev_dir = app_dev_dir(app)
    new_app_dir = app_dir('new_subdomain')
    new_app_dev_dir = app_dev_dir('new_subdomain')

    with_app(app) do
      subject.execute

      expect(old_app_dir.exist?).to be_truthy
      expect(new_app_dir.exist?).to be_falsy

      expect(old_app_dev_dir.exist?).to be_truthy
      expect(new_app_dev_dir.exist?).to be_falsy

      # ensure to remove correct dir when leaving with_app
      app.reload
    end
  end

  it 'creates activity log for update' do
    params = { name: 'New name' }
    subject = UpdateAppService.new(author, app, params)

    with_app(app) do
      expect { subject.execute }.to change { Activity.count }.by 1
      activity = app.activities.last

      expect(activity.activity_type).to eq 'updated'
      expect(activity.author).to eq author
    end
  end
end
