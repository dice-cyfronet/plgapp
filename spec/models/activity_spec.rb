require 'rails_helper'

RSpec.describe Activity do
  subject { Activity.new(app: build(:app), author: build(:user)) }

  it { should validate_presence_of(:app).with_message('must exist') }
  it { should validate_presence_of(:author).with_message('must exist') }
end
