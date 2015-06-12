class Users::SessionsController < Devise::SessionsController
  include Subdomainable

  prepend_before_filter :set_app, only: :new, if: :subdomain?
end
