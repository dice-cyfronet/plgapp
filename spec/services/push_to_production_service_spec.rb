require 'rails_helper'

RSpec.describe PushToProductionService do
  include AppSpecHelper
  include AppFilesHelper

  let(:author) { create(:user) }
  let(:app) { build(:app) }

  before { CreateAppService.new(author, app).execute }

  it 'copies files from dev into production' do
    with_app(app) do
      create_dev_file(app, 'foo.txt', 'bar')

      described_class.new(author, app).execute

      expect(prod_file('foo.txt')).to be_exist
    end
  end

  it 'removes all files from production' do
    with_app(app) do
      create_prod_file(app, 'foo.txt', 'bar')

      described_class.new(author, app).execute

      expect(prod_file('foo.txt')).to_not be_exist
    end
  end

  it 'creates activity log' do
    with_app(app) do
      expect { described_class.new(author, app, message: 'msg').execute }.
        to change { Activity.count }.by 1
      activity = app.activities.last

      expect(activity.activity_type).to eq 'deployment'
      expect(activity.author).to eq author
      expect(activity.message).to eq 'msg'
    end
  end

  def prod_file(name)
    Pathname.new(app_file_path(app.subdomain, name))
  end
end
