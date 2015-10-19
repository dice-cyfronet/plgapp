require 'clean_path'

class GetAppFileService
  include CleanPath

  def initialize(app, dev, path)
    @app = app
    @dev = dev
    @path = path
  end

  def execute
    file = Pathname.new(content_path).join(clean_path(@path))

    if file.directory?
      index = file.join('index.html')
      file = index.exist? ? index : nil
    end

    file
  end

  private

  def content_path
    Pathname.new(user_apps_dir).join(app_dir)
  end

  def app_dir
    if dev?
      "#{@app.subdomain}#{Rails.configuration.dev_postfix}"
    else
      @app.subdomain
    end
  end

  def user_apps_dir
    Rails.configuration.apps_dir
  end

  def dev?
    @dev
  end
end
