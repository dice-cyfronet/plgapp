require 'rails_helper'

RSpec.describe Dropbox::UpdateUsersAppsService do
  it 'shedule update jobs' do
    u1 = create(:user, dropbox_user: '1')
    create(:user, dropbox_user: '2')

    app1, app2, app3 = create_list(:app, 4)

    app1.app_members.create(user: u1, dropbox_enabled: true)
    app2.app_members.create(user: u1, dropbox_enabled: true)
    app3.app_members.create(user: u1, dropbox_enabled: false)

    expect(Dropbox::UpdateUserAppJob).to receive(:perform_later).with(u1, app1)
    expect(Dropbox::UpdateUserAppJob).to receive(:perform_later).with(u1, app2)

    described_class.new(['1', '2']).execute
  end
end
