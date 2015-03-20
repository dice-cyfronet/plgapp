class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'errors'

  def not_found
  end

  def unprocessable
  end

  def internal_server_error
  end
end
