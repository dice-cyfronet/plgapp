class PushToProductionService < AppService
  def initialize(author, app, options = {})
    super(author, app)
    @options = options
  end

  def execute
    FileUtils.rm_rf("#{app_dir(app)}/.")
    FileUtils.cp_r("#{app_dev_dir(app)}/.", app_dir(app))

    build_activity(:deployment, @options[:message]).save

    true
  rescue
    false
  end
end
