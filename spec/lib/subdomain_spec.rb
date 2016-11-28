require 'rails_helper'

RSpec.describe Subdomain do
  it 'subdoamin as root domain' do
      expect(described_class.matches?(request('app'))).to be_falsy
  end

  it 'matches subdomain' do
      expect(described_class.matches?(request('sub.app'))).to be_truthy
  end

  it 'reject www' do
    expect(described_class.matches?(request('www.app'))).to be_falsy
  end

  def request(subdomain)
    ActionController::TestRequest.create.tap do |r|
      r.host = "#{subdomain}.example.com"
    end
  end
end
