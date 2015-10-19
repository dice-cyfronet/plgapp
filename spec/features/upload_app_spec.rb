require 'rails_helper'

RSpec.feature 'Upload app' do
  include AppSpecHelper

  scenario 'upload file zip' do
    with_app do |app|
      app_owner_log_in(app)
      dev_app_dir = app.dev_subdomain

      visit zip_app_deploy_path(app)
      attach_file(I18n.t('simple_form.labels.app.content'),
                  Rails.root.join('spec', 'resources', 'app.zip'))
      click_button(I18n.t('apps.zip_upload'))

      expect(File.exist?(app_file_path(dev_app_dir, '1.txt'))).to be_truthy
      expect(File.exist?(app_file_path(dev_app_dir, '2.txt'))).to be_truthy
      expect(File.exist?(app_file_path(dev_app_dir, 'sub/3.txt'))).to be_truthy
    end
  end
end
