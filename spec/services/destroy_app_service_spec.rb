require 'rails_helper'

RSpec.describe DestroyAppService do
  include AppSpecHelper

  let(:app) { build(:app) }
  subject { DestroyAppService.new(app) }

  before { CreateAppService.new(create(:user), app).execute }

  it 'removes app' do
    expect { subject.execute }.
      to change { App.count }.by(-1)
  end

  it 'removes app dir' do
    subject.execute

    expect(app_dir(app).exist?).to be_falsy
    expect(app_dev_dir(app).exist?).to be_falsy
  end
end