require 'rails_helper'
require 'proxy/datanet'

RSpec.feature 'Datanet proxy' do
  include AppSpecHelper

  it 'redirect request into datanet' do
    proxy = instance_double(Proxy::Datanet)
    allow(Proxy::Datanet).
      to receive(:new).
      and_return(proxy)

    logged_in_subdomain('dummy') do
      expect(proxy).
        to receive(:call).
        and_return([200, {}, 'body'])

      visit '/datanet/valid-repo-name/index.html'

      expect(page.status_code).to eq 200
      expect(page.body).to eq 'body'
    end
  end

  it 'validate proxy name (only letters, digits and -)' do
    logged_in_subdomain('dummy') do
      visit '/datanet/0x9C11C1DC%2f/index.html'

      expect(page.status_code).to eq 400
    end
  end
end
