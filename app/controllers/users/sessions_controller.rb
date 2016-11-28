class Users::SessionsController < Devise::SessionsController
  include Subdomainable

  prepend_before_action :set_app, only: :new, if: :subdomain?
end
