require 'rails_helper'

RSpec.describe AppMember do
  it 'first app member receives :master role by default' do
    user = create(:user)
    app = create(:app)

    app.users << user

    expect(app.app_members.first).to be_master
  end

  it 'next app member receives :developer role by default' do
    u1 = create(:user)
    u2 = create(:user)
    app = create(:app)

    app.users << u1
    app.users << u2

    expect(u2.app_members.first).to be_developer
  end
end
