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

    get '/:id', to: 'subdomains#show', id: /.*/
  end

  constraints(Root) do
    resources :apps
    get 'help', to: 'help#show'
    get 'help/:category', to: 'help#show', as: 'help_file'
  end

  root 'home#index'

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
