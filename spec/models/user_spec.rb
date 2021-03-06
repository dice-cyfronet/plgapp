require 'rails_helper'

RSpec.describe User do
  it { should have_many(:app_members).dependent(:destroy) }
  it { should have_many(:apps) }
  it { should have_many(:activities).dependent(:nullify) }
  it { should validate_inclusion_of(:locale).in_array(%w(pl en)) }

  it 'creates new user while logging using omniauth' do
    expect { User.from_plgrid_omniauth(auth) }.to change { User.count }.by(1)
  end

  it 'sets user details while logging using omniauth' do
    user = User.from_plgrid_omniauth(auth)

    expect(user.login).to eq 'johndoe'
    expect(user.name).to eq 'John Doe'
    expect(user.email).to eq 'a@b.c'
  end

  it 'reuse user account' do
    create(:user, login: 'johndoe')

    expect { User.from_plgrid_omniauth(auth) }.to change { User.count }.by(0)
  end

  def auth
    double('auth',
           info: double(email: 'a@b.c', name: 'John Doe', nickname: 'johndoe'))
  end
end
