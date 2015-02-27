require 'rails_helper'

RSpec.describe CreateAppService do
  include AppSpecHelper

  let(:author) { create(:user) }
  let(:app) { build(:app) }
  subject { CreateAppService.new(author, app) }

  it 'creates new app' do
    with_app(app) do
      expect { subject.execute }.
        to change { App.count }.by 1
    end
  end

  it 'creates folder for the app' do
    with_app(app) do
      subject.execute

      expect(app_dir(app).exist?).to be_truthy
    end
  end

  it 'creates folder only when app is saved sucessfully' do
    app.name = nil

    subject.execute

    expect(app_dir(app).exist?).to be_falsy
  end

  it 'creates activity log' do
    expect { subject.execute }.to change { Activity.count }.by 1
    activity = app.activities.first

    expect(activity.activity_type).to eq 'created'
    expect(activity.author).to eq author
  end

  it 'does not create activity log when save failed' do
    app.name = nil

    expect { subject.execute }.to change { Activity.count }.by 0
  end
end
