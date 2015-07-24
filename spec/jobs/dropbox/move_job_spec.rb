require 'rails_helper'

RSpec.describe Dropbox::MoveJob do
  it 'rename dropbox file' do
    user = double
    service = instance_double(Dropbox::MoveService)
    expect(service).to receive(:execute)

    expect(Dropbox::MoveService).
      to receive(:new).
      with(user, 'from', 'to').
      and_return(service)

    subject.perform(user, 'from', 'to')
  end
end
