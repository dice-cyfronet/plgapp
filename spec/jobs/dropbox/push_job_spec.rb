require 'rails_helper'

RSpec.describe Dropbox::PushJob do
  EN_COLLISION_MSG = 'subdomain (collision, moved at 2015-06-17 13:03:23 UTC)'
  PL_COLLISION_MSG =
    'subdomain (konflikt, przeniesiony 2015-06-17 13:03:23 UTC)'

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

  it 'checks for dir collision and move if necessary on first push' do
    allow_push_services(EN_COLLISION_MSG)

    expect(move_service).to receive(:execute)

    subject.perform(user, app)
  end

  it 'respect user locale' do
    user.locale = 'pl'
    allow_push_services(PL_COLLISION_MSG)

    expect(move_service).to receive(:execute)

    subject.perform(user, app)
  end

  it 'don\'t check for collision after first push' do
    allow_push_services(EN_COLLISION_MSG)

    app_member = app.app_members.find_by(user: user)
    app_member.dropbox_entries.create(path: '/', is_dir: true)

    expect(move_service).to_not receive(:execute)

    subject.perform(user, app)
  end

  it 'add app to dropbox' do
    allow_push_services(EN_COLLISION_MSG)

    expect(push_service).to receive(:execute)

    subject.perform(user, app)
  end

  def allow_push_services(collision_dir_name)
    allow(Dropbox::PushService).
      to receive(:new).
      with(user, app).
      and_return(push_service)

    allow(Time).to receive(:now).
      and_return(Time.utc(2015, 6, 17, 13, 3, 23))
    allow(Dropbox::MoveService).
      to receive(:new).
      with(user, 'subdomain', collision_dir_name).
      and_return(move_service)
  end
end
