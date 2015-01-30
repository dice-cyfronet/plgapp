require 'subdomain'

Rails.application.routes.draw do
  get '/' => 'apps#subdomain', constraints: Subdomain

  root 'apps#index'

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :apps
end
