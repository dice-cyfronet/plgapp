require 'rails_helper'

RSpec.describe AppsController do
  include Warden::Test::Helpers

  let(:user) { create(:user) }
  before { sign_in(user) }

  it 'shows only applications owned by the user' do
    app1 = create(:app, author: user)
    app2 = create(:app, author: user)
    create(:app)

    get :index

    expect(response).to have_http_status(:success)
    expect(assigns(:apps)).to contain_exactly(app1, app2)
  end

  it 'show owned app' do
    app = create(:app, author: user)

    get :show, id: app.id

    expect(response).to have_http_status(:success)
    expect(assigns(:app)).to eq app
  end

  it 'unable to see not owned app' do
    app = create(:app)
    get :show, id: app.id

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
      app = create(:app, author: user)

      get :edit, id: app.id

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
      expect(assigns(:app)).to eq app
    end

    it 'is forbidden for no author' do
      app = create(:app)

      get :edit, id: app.id

      expect_no_authorized
    end

    it 'updates parameters' do
      app = create(:app, author: user)

      put :update, app: { name: 'updated', subdomain: 'newsub' }, id: app.id
      app.reload

      expect(app.name).to eq 'updated'
      expect(app.subdomain).to eq 'newsub'
      expect(response).to redirect_to app_path(app)
    end
  end

  context 'destroy app' do
    it 'assigned to the user' do
      app = create(:app, author: user)

      expect { delete :destroy, id: app.id }.
        to change { App.count }.by -1
      expect(response).to redirect_to apps_path
    end

    it 'is forbidden for no author' do
      app = create(:app)

      delete :destroy, id: app.id

      expect_no_authorized
    end
  end

  def expect_no_authorized
    expect(response).to redirect_to root_path
    expect(flash[:alert]).to match(/not authorized/)
  end
end
