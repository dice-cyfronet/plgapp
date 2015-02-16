require 'subdomain'

Rails.application.routes.draw do
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  constraints(Subdomain) do
    get '/:id', to: 'subdomains#show', id: /.*/
  end

  devise_for :users,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :apps

  root 'apps#index'
end
