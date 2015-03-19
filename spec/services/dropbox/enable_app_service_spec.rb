require 'rails_helper'

RSpec.describe Dropbox::EnableAppService do
  let(:user) { create(:user) }
  let(:app) { create(:app, users: [user]) }

  it 'enable dropbox for app' do
    service.execute
    app_member = app.app_members.find_by(user: user)

    expect(app_member).to be_dropbox_enabled
  end

  it 'push changes into dropbox' do
    expect(Dropbox::PushJob).to receive(:perform_later).with(user, app)

    service.execute
  end

  def service
    described_class.new(user, app)
  end
end
