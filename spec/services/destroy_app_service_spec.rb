require 'rails_helper'

RSpec.describe DestroyAppService do
  include AppSpecHelper

  let(:app) { build(:app) }
  subject { DestroyAppService.new(app) }

  before { CreateAppService.new(create(:user), app).execute }

  it 'removes app' do
    expect { subject.execute }.
      to change { App.count }.by(-1)
  end

  it 'removes app dir' do
    subject.execute

    expect(app_dir(app).exist?).to be_falsy
    expect(app_dev_dir(app).exist?).to be_falsy
  end

  it 'triggers app removal from dropbox' do
    u1, u2, u3 = create_list(:user, 3)

    app.app_members.create(user: u1, dropbox_enabled: true)
    app.app_members.create(user: u2, dropbox_enabled: true)
    app.app_members.create(user: u3, dropbox_enabled: false)

    expect_delete_from_dropbox_for(u1)
    expect_delete_from_dropbox_for(u2)

    subject.execute
  end

  def expect_delete_from_dropbox_for(user)
    expect(Dropbox::DeleteJob).
      to receive(:perform_later).
      with(user, app.subdomain)
  end
end
