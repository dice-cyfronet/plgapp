require 'rails_helper'

RSpec.describe AppsController do
  include Warden::Test::Helpers
  include AppSpecHelper

  let(:user) { create(:user) }
  before { login_as(user) }

  before do
    allow(FileUtils).to receive(:mkdir_p)
    allow(FileUtils).to receive(:rm_rf)
    allow(FileUtils).to receive(:mv)
    allow(Dir).to receive(:entries).and_return(['f1', 'f2'])
  end

  it 'shows only applications owned by the user' do
    app1 = create(:app, users: [user])
    app2 = create(:app, users: [user])
    app3 = create(:app)

    get apps_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include(app1.name)
    expect(response.body).to include(app2.name)
    expect(response.body).to_not include(app3.name)
  end

  it 'show owned app' do
    app = create(:app, users: [user])

    get app_path(app.subdomain)

    expect(response).to have_http_status(:success)
    expect(response.body).to include(app.name)
  end

  it 'unable to see not owned app' do
    app = create(:app)
    get app_path(app.subdomain)

    expect_no_authorized
  end

  context 'creats new app' do
    it 'assigned to current user' do
      params = { app: { name: 'my app', subdomain: 'test' } }

      expect { post apps_path, params: params }.
        to change { App.count }.by 1
      expect(flash[:notice]).to match(/successfully created/)
    end
  end

  context 'edit app' do
    it 'assigned to the user' do
      app = user_app

      get edit_app_path(app.subdomain)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(app.name)
    end

    it 'is forbidden for no author' do
      app = create(:app)

      get edit_app_path(app.subdomain)

      expect_no_authorized
    end

    it 'updates parameters' do
      app = user_app

      put app_path(app.subdomain),
          params: { app: { name: 'updated', subdomain: 'newsub' } }
      app.reload

      expect(app.name).to eq 'updated'
      expect(app.subdomain).to eq 'newsub'
      expect(response).to redirect_to app_path(app)
    end
  end

  context 'destroy app' do
    it 'assigned to the user' do
      app = user_app

      expect{ delete app_path(app.subdomain) }.to change { App.count }.by(-1)
      expect(response).to redirect_to apps_path
    end

    it 'is forbidden for no author' do
      app = create(:app)

      delete app_path(app.subdomain)

      expect_no_authorized
    end
  end

  context 'push to production' do
    it 'show success when everything is ok' do
      app = user_app
      expect(PushToProductionService).to receive(:new).
        and_return(double(execute: true))

      put push_app_path(app.subdomain)

      expect(response).to redirect_to zip_app_deploy_path(app)
    end
  end

  def expect_no_authorized
    expect(response).to redirect_to root_path
    expect(flash[:alert]).to match(/not authorized/)
  end

  def user_app
    create(:app).tap do |app|
      app.app_members.create(user: user, role: :master)
    end
  end
end
