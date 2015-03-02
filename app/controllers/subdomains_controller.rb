class SubdomainsController < ApplicationController
  include Subdomainable

  VALID_CHARACTERS = "a-zA-Z0-9~!@$%^&*()#`_+-=<>\"{}|[];',?".freeze

  skip_before_action :verify_authenticity_token
  before_filter :set_app

  def show
    if file && file.exist?
      send_file file, disposition: 'inline'
    else
      not_found!
    end
  end

  def info
    render json: {
      csrfToken: form_authenticity_token,
      userLogin: current_user.login
    }
  end

  private

  def file
    @file ||= Pathname.new(content_path).join(clean_path)

    if @file.directory?
      index = @file.join('index.html')
      @file = index.exist? ? index : nil
    end

    @file
  end

  def content_path
    Pathname.new(user_apps_dir).join(subdomain)
  end

  def user_apps_dir
    Rails.configuration.apps_dir
  end

  def clean_path
    path = Pathname.new("/#{clean_id}")
    path.cleanpath.to_s[1..-1]
  end

  def clean_id
    (params[:id] || '').tr("^#{VALID_CHARACTERS}", '')
  end
end
