require 'rails_helper'

RSpec.describe Dropbox::DeleteJob do
  it 'deletes dropbox subdomain' do
    user = double
    service = instance_double(Dropbox::DeleteService)
    expect(service).to receive(:execute)

    expect(Dropbox::DeleteService).
      to receive(:new).
      with(user, 'to_delete').
      and_return(service)

    subject.perform(user, 'to_delete')
  end
end
