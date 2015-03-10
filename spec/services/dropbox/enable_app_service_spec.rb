require 'rails_helper'

RSpec.describe Dropbox::EnableAppService do
  it 'enable dropbox for app' do
    user = create(:user)
    app = create(:app, users: [user])

    described_class.new(user, app).execute
    app_member = app.app_members.find_by(user: user)

    expect(app_member).to be_dropbox_enabled
  end
end
