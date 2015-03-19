require 'subdomain'
require 'root'

Rails.application.routes.draw do
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  constraints(Subdomain) do
    devise_scope :user do
      get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    end

    match '/rimrock/:id',
          to: 'rimrock#call',
          via: [:get, :post, :put, :delete],
          id: /.*/

    match '/plgdata/:id',
          to: 'plgdata#call',
          via: [:get, :post, :put, :delete],
          id: /.*/

    get '/info', to: 'subdomains#info', as: :info
    get '/:id', to: 'subdomains#show', id: /.*/
  end

  constraints(Root) do
    devise_scope :user do
      get 'sign_in', to: 'home#index'
    end

    get '/dropbox/auth_finish',
        to: 'dropboxes#auth_finish',
        as: :dropbox_auth_finish

    get '/dropbox/webhook',
        to: 'dropboxes#webhook_verify'

    post '/dropbox/webhook',
         to: 'dropboxes#delta'

    resources :apps do
      member do
        get :download
        get :activity
        put :push
      end

      resource :deploy, only: [:show] do
        member do
          get :zip
          get :dropbox
        end
      end

      resource :dropbox, only: [:update, :destroy]
    end
    get 'help', to: 'help#show'
    get 'help/:category', to: 'help#show', as: 'help_file'
  end

  root 'home#index'

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
