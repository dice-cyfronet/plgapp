require 'rails_helper'

RSpec.describe GetAppFileService do
  let(:app) { build(:app, subdomain: 'dummy') }

  it 'returns production index file' do
    subject = GetAppFileService.new(app, false, '')

    path = subject.execute

    expect(path).to eq apps_dir.join('dummy', 'index.html')
  end

  it 'returns devel index file' do
    subject = GetAppFileService.new(app, true, '')

    path = subject.execute

    expect(path).to eq apps_dir.join('dummy-dev', 'index.html')
  end

  it 'dont allow to got up the user dirr' do
    subject = GetAppFileService.new(app, true, '../../../index.html')

    path = subject.execute

    expect(path).to eq apps_dir.join('dummy-dev', 'index.html')
  end

  it 'allow to traverse inside app dir' do
    subject = GetAppFileService.new(app, true, 'js/../index.html')

    path = subject.execute

    expect(path).to eq apps_dir.join('dummy-dev', 'index.html')
  end

  def apps_dir
    Pathname.new(Rails.configuration.apps_dir)
  end
end
