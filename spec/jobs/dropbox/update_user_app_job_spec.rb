require 'rails_helper'

RSpec.describe Dropbox::UpdateUserAppJob do
  it 'fetch changes from dropbox' do
    u1, u2, u3 = create_list(:user, 3)
    app = create(:app)

    app.app_members.create(user: u1, dropbox_enabled: true)
    app.app_members.create(user: u2, dropbox_enabled: true)
    app.app_members.create(user: u3, dropbox_enabled: false)

    pull_service = instance_double(Dropbox::PullService)
    expect(pull_service).to receive(:execute).and_return(true)

    push_service = instance_double(Dropbox::PushService)
    expect(push_service).to receive(:execute).and_return(true)

    allow(Dropbox::PullService).
      to receive(:new).
      with(u1, app).
      and_return(pull_service)

    expect(Dropbox::PushService).
      to receive(:new).
      with(u2, app).
      and_return(push_service)

    subject.perform(u1, app)
  end

  it 'does not push changes further when no changes' do
    u1, u2 = create_list(:user, 2)
    app = create(:app)

    app.app_members.create(user: u1, dropbox_enabled: true)
    app.app_members.create(user: u2, dropbox_enabled: true)

    allow(Dropbox::PullService).
      to receive(:new).
      with(u1, app).
      and_return(double(execute: false))

    expect(Dropbox::PushService).to_not receive(:new)

    subject.perform(u1, app)
  end
end
