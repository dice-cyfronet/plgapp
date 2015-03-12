module AppFilesHelper
  def create_dev_file(app, name, content)
    create_app_file(app.dev_subdomain, name, content)
  end

  def create_dev_dir(app, name)
    create_dir(app.dev_subdomain, name)
  end

  def create_prod_file(app, name, content)
    create_app_file(app.subdomain, name, content)
  end

  private

  def create_app_file(app_subdomain, name, content)
    path = app_file_path(app_subdomain, name)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') { |file| file.write(content) }
  end

  def create_dir(app_subdomain, name)
    path = app_file_path(app_subdomain, name)
    FileUtils.mkdir_p(path)
  end
end
