require 'rails_helper'

RSpec.describe Dropbox::PullService do
  include AppSpecHelper
  include AppFilesHelper

  let(:author) { create(:user) }
  let(:app) { build(:app, users: [author]) }
  let(:client) { instance_double('DropboxClient') }
  let(:app_member) { app.app_members.find_by(user: author) }

  it 'pull new files' do

  end


  def service
    described_class.new(author, app, client: client)
  end
end