require 'rails_helper'

RSpec.describe Dropbox::PushJob do
  it 'add app to dropbox' do
    user = double('user')
    app = double('app')
    service = instance_double(Dropbox::PushService)
    expect(service).to receive(:execute)

    expect(Dropbox::PushService).
      to receive(:new).
      with(user, app).
      and_return(service)

    subject.perform(user, app)
  end
end
