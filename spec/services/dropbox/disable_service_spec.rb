require 'rails_helper'

RSpec.describe Dropbox::DisableService do
  let(:user) do
    create(:user, dropbox_user: '123', dropbox_access_token: 'token')
  end

  subject { described_class.new(user) }

  it 'cleans dropbox user credentials' do
    subject.execute
    user.reload

    expect(user.dropbox_user).to be_blank
    expect(user.dropbox_access_token).to be_blank
  end

  it 'disabled dropbox integration with all user apps' do
    app_member = user_app_member

    subject.execute
    app_member.reload

    expect(app_member.dropbox_enabled).to be_blank
    expect(app_member.dropbox_cursor).to be_blank
  end

  it 'deletes all dropbox entries' do
    app_member = user_app_member
    app_member.dropbox_entries.create(path: '/a', is_dir: true)
    app_member.dropbox_entries.create(path: '/a/b')

    subject.execute

    expect(app_member.dropbox_entries.count).to eq 0
  end

  it 'notify user about dropbox disconnection' do
    expect { subject.execute }.
      to change(ActionMailer::Base.deliveries, :count).by(1)
  end

  def user_app_member
    app = create(:app)
    user.apps << app
    AppMember.find_by(app_id: app.id, user_id: user.id).tap do |app_member|
      app_member.update_attributes(dropbox_enabled: true, dropbox_cursor: '123')
    end
  end
end
