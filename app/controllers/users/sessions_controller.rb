class Users::SessionsController < Devise::SessionsController
  include Subdomainable

  before_filter :set_app, only: :new, if: :subdomain?
end