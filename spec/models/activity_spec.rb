require 'rails_helper'

RSpec.describe Activity do
  it { should validate_presence_of :app }
  it { should validate_presence_of :author }
end
