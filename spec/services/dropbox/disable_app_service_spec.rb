require 'rails_helper'

RSpec.describe Dropbox::DisableAppService do
  it 'enable dropbox for app' do
    user, app, app_member = user_app

    described_class.new(user, app).execute
    app_member.reload

    expect(app_member).to_not be_dropbox_enabled
  end

  it 'remove dropbox token when last app' do
    user, app, _ = user_app

    described_class.new(user, app).execute
    user.reload

    expect(user.dropbox_access_token).to be_nil
  end

  def user_app
    user = create(:user, dropbox_access_token: 'token')
    app = create(:app)
    app_member = app.app_members.create(user: user, dropbox_enabled: true)

    [user, app, app_member]
  end
end
