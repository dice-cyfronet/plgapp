require 'rails_helper'

RSpec.describe Dropbox::PushJob do
  let(:push_service) do
    instance_double(Dropbox::PushService).tap do |service|
      allow(service).to receive(:execute)
    end
  end
  let(:move_service) do
    instance_double(Dropbox::MoveService).tap do |service|
      allow(service).to receive(:execute)
    end
  end

  let(:user) { create(:user) }
  let(:app) { create(:app, subdomain: 'subdomain', users: [user]) }

  before do
    allow(Dropbox::PushService).
      to receive(:new).
      with(user, app).
      and_return(push_service)

    allow(Time).to receive(:now).
      and_return(Time.utc(2015, 6, 17, 13, 3, 23))
    allow(Dropbox::MoveService).
      to receive(:new).
      with(user, 'subdomain',
          'subdomain (collision, moved at 2015-06-17 13:03:23 UTC)').
      and_return(move_service)
  end

  it 'checks for dir collision and move if necessary on first push' do
    expect(move_service).to receive(:execute)

    subject.perform(user, app)
  end

  it 'don\'t check for collision after first push' do
    app_member = app.app_members.find_by(user: user)
    app_member.dropbox_entries.create(path: '/', is_dir: true)

    expect(move_service).to_not receive(:execute)

    subject.perform(user, app)
  end

  it 'add app to dropbox' do
    expect(push_service).to receive(:execute)

    subject.perform(user, app)
  end
end
