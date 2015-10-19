require 'rails_helper'

RSpec.describe AppsController do
  include Warden::Test::Helpers

  let(:user) { create(:user) }
  before { sign_in(user) }

  before do
    allow(FileUtils).to receive(:mkdir_p)
    allow(FileUtils).to receive(:rm_rf)
    allow(FileUtils).to receive(:mv)
  end

  it 'shows only applications owned by the user' do
    app1 = create(:app, users: [user])
    app2 = create(:app, users: [user])
    create(:app)

    get :index

    expect(response).to have_http_status(:success)
    expect(assigns(:apps)).to contain_exactly(app1, app2)
  end

  it 'show owned app' do
    app = create(:app, users: [user])

    get :show, id: app.subdomain

    expect(response).to have_http_status(:success)
    expect(assigns(:app)).to eq app
  end

  it 'unable to see not owned app' do
    app = create(:app)
    get :show, id: app.subdomain

    expect_no_authorized
  end

  context 'creats new app' do
    it 'assigned to current user' do
      params = { app: { name: 'my app', subdomain: 'test' } }

      expect { post :create, params }.
        to change { App.count }.by 1
      expect(flash[:notice]).to match(/successfully created/)
    end
  end

  context 'edit app' do
    it 'assigned to the user' do
      app = user_app

      get :edit, id: app.subdomain

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
      expect(assigns(:app)).to eq app
    end

    it 'is forbidden for no author' do
      app = create(:app)

      get :edit, id: app.subdomain

      expect_no_authorized
    end

    it 'updates parameters' do
      app = user_app

      put :update,
          id: app.subdomain,
          app: { name: 'updated', subdomain: 'newsub' }
      app.reload

      expect(app.name).to eq 'updated'
      expect(app.subdomain).to eq 'newsub'
      expect(response).to redirect_to app_path(app)
    end
  end

  context 'destroy app' do
    it 'assigned to the user' do
      app = user_app

      expect { delete :destroy, id: app.subdomain }.
        to change { App.count }.by -1
      expect(response).to redirect_to apps_path
    end

    it 'is forbidden for no author' do
      app = create(:app)

      delete :destroy, id: app.subdomain

      expect_no_authorized
    end
  end

  context 'push to production' do
    it 'show success when everything is ok' do
      app = user_app
      expect(PushToProductionService).to receive(:new).
        and_return(double(execute: true))

      put :push, id: app.subdomain

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
