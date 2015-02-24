require 'rails_helper'

RSpec.feature 'Upload app' do
  include AppSpecHelper
  include Warden::Test::Helpers

  scenario 'upload file zip' do
    with_app do |app|
      app_owner_log_in(app)

      visit app_path(app)
      attach_file('Content',
                  Rails.root.join('spec', 'resources', 'app.zip'))
      click_button('Update App')

      expect(File.exist?(app_file_path(app, '1.txt'))).to be_truthy
      expect(File.exist?(app_file_path(app, '2.txt'))).to be_truthy
      expect(File.exist?(app_file_path(app, 'sub/3.txt'))).to be_truthy
    end
  end

  def app_owner_log_in(app)
    owner = create(:user)
    app.users << owner
    login_as(owner, scope: :user)
  end
end
