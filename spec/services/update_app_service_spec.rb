require 'rails_helper'

RSpec.describe UpdateAppService do
  include AppSpecHelper

  let(:app) { build(:app) }

  before { CreateAppService.new(app).execute }

  it 'updates app attributes' do
    params = { name: 'New name' }
    subject = UpdateAppService.new(app, params)

    with_app(app) do
      subject.execute

      expect(app.name).to eq 'New name'
    end
  end

  it 'rename app dir when subdomain changed' do
    params = { subdomain: 'new_subdomain' }
    subject = UpdateAppService.new(app, params)
    old_app_dir = app_dir(app)

    with_app(app) do
      subject.execute

      expect(old_app_dir.exist?).to be_falsy
      expect(app_dir(app).exist?).to be_truthy
    end
  end

  it 'does not rename app dir when update failed' do
    params = { subdomain: 'new_subdomain', name: nil }
    subject = UpdateAppService.new(app, params)
    old_app_dir = app_dir(app)

    with_app(app) do
      subject.execute

      expect(old_app_dir.exist?).to be_truthy
    end
  end
end