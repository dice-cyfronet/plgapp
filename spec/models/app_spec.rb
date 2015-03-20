require 'rails_helper'

RSpec.describe App do
  subject { build(:app) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :subdomain }
  it { should validate_uniqueness_of :subdomain }

  it { should have_many(:app_members).dependent(:destroy) }
  it { should have_many(:users).through(:app_members) }
  it { should have_many(:activities).dependent(:destroy) }

  context 'app slug' do
    it 'is converted into safe slug' do
      my_app = create(:app, subdomain: '../\a b#?^&%')

      expect(my_app.subdomain).to eq 'a-b'
    end
  end

  it 'takes into account domain prefix' do
    my_app = create(:app, subdomain: 'my-app')

    expect(my_app.full_subdomain).to eq 'my-app.app'
  end

  context 'reserved dev postfix' do
    it 'disallow -dev at the end of subdomain name' do
      my_app = build(:app, subdomain: 'app-dev')

      expect(my_app.valid?).to be_falsy
    end
  end

  it 'adds dev postfix for dev subdomain' do
    app = build(:app, subdomain: 'my_app')

    expect(app.dev_subdomain).to eq 'my_app-dev'
  end

  context 'full domain path' do
    let(:app) { build(:app, subdomain: 'my_app') }

    it 'for production app' do
      expect(app.full_subdomain).to eq 'my_app.app'
    end

    it 'for devel app' do
      expect(app.dev_full_subdomain).to eq 'my_app-dev.app'
    end
  end

  context '#old_subdomain' do
    it 'saves old subdomain value' do
      app = create(:app, subdomain: 'old')

      app.update_attributes(subdomain: 'new')

      expect(app.old_subdomain).to eq 'old'
    end
  end
end
