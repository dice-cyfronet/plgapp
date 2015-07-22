require 'rails_helper'

RSpec.describe Dropbox::Operation do
  let(:service) { double('service') }
  let(:author) { double('author', login: 'author') }

  class RealOperation < Dropbox::Operation
    def initialize(author, app, service)
      super(author, app, client: 'client')
      @service = service
    end

    protected

    def internal_execute
      @service.internal_execute
    end
  end

  subject { RealOperation.new(author, build(:app), service) }

  it 'executes service' do
    expect(service).to receive(:internal_execute)

    subject.execute
  end

  it 'disconnects all user apps from dropbox when dropbox auth error' do
    allow(service).
      to receive(:internal_execute).
      and_raise(DropboxAuthError, 'auth error')

    expect(Dropbox::DisableJob).
      to receive(:perform_later).with(author)

    subject.execute
  end
end
