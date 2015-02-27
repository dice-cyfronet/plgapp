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

    get '/csrf_token', to: 'subdomains#csrf_token', as: :csrf_token
    get '/:id', to: 'subdomains#show', id: /.*/
  end

  constraints(Root) do
    devise_scope :user do
      get 'sign_in', to: 'home#index'
    end

    resources :apps do
      member do
        get :download
        get :deploy
        get :activity
      end
    end
    get 'help', to: 'help#show'
    get 'help/:category', to: 'help#show', as: 'help_file'
  end

  root 'home#index'

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
