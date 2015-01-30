class SubdomainsController < ApplicationController
  VALID_CHARACTERS = "a-zA-Z0-9~!@$%^&*()#`_+-=<>\"{}|[];',?".freeze

  before_filter :set_app

  def show
    if file && file.exist?
      render file: file,
             status: 200,
             layout: false
    else
      not_found
    end
  end

  private

  def set_app
    @app = App.find_by!(subdomain: request.subdomain)
  end

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

  def subdomain
    @app.subdomain
  end

  def user_apps_dir
    Rails.application.config_for('user_apps')['apps_dir']
  end

  def clean_path
    path = Pathname.new("/#{clean_id}")
    path.cleanpath.to_s[1..-1]
  end

  def clean_id
    (params[:id] || '').tr("^#{VALID_CHARACTERS}", '')
  end
end
