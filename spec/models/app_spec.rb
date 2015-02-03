require 'rails_helper'

RSpec.describe App do
  subject { build(:app) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :subdomain }
  it { should validate_uniqueness_of :subdomain }

  context 'app slug' do
    it 'is converted into safe slug' do
      my_app = create(:app, subdomain: '../\a b#?^&%')

      expect(my_app.subdomain).to eq 'a-b'
    end
  end
end
