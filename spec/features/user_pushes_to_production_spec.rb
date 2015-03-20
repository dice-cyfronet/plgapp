require 'rails_helper'

RSpec.feature 'User pushes to production' do
  include AppSpecHelper
  include AppFilesHelper

  let(:author) { create(:user) }
  let(:app) { build(:app) }

  before { CreateAppService.new(author, app).execute }
  after { DestroyAppService.new(app).execute }

  scenario 'push dev version into production' do
    create_dev_file(app, 'foo.html', '<html><body>bar</body></html>')

    app_owner_log_in(app)
    visit zip_app_deploy_path(app)
    find(:linkhref, push_app_path(app)).click

    in_subdomain(app.full_subdomain) do
      login_as(author, scope: :user)

      visit '/foo.html'

      expect(page).to have_content 'bar'
    end
  end
end
