require 'rails_helper'

RSpec.describe Dropbox::DisableJob do
  it 'disconnect all user apps from dropbox' do
    user = double
    service = instance_double(Dropbox::DisableService)
    expect(service).to receive(:execute)

    expect(Dropbox::DisableService).
      to receive(:new).with(user).
      and_return(service)

    subject.perform(user)
  end
end
