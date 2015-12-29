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
    @dev ? @app.app_dev_dir : @app.app_dir
  end
end
