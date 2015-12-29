require 'rails_helper'

RSpec.feature 'Download app content as zip' do
  include AppSpecHelper
  include AppFilesHelper

  scenario 'with app files' do
    with_app do |app|
      create_dev_file(app, 'foo.html', '<html><body>bar</body></html>')

      app_owner_log_in(app)
      visit download_app_path(app)

      expect(page.response_headers['Content-Type']).to eq 'application/zip'
    end
  end

  scenario 'with empty app (no files inside app directory) show notice' do
    with_app do |app|
      app_owner_log_in(app)
      visit download_app_path(app)

      expect(page).to have_content(I18n.t('apps.empty'))
    end
  end
end
