require 'rails_helper'

RSpec.describe CreateAppService do
  include AppSpecHelper

  let(:app) { build(:app) }
  subject { CreateAppService.new(app) }

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
end
