require 'rails_helper'

RSpec.describe Dropbox::UpdateUsersAppsService do
  it 'shedule update jobs' do
    expect(Dropbox::UpdateUserAppsJob).to receive(:perform_later).with('1')
    expect(Dropbox::UpdateUserAppsJob).to receive(:perform_later).with('2')

    described_class.new(['1', '2']).execute
  end
end