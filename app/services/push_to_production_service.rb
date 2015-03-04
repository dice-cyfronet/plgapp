class PushToProductionService < AppService
  def execute
    FileUtils.rm_rf("#{app_dir(app)}/.")
    FileUtils.cp_r("#{app_dev_dir(app).join()}/.", app_dir(app))

    build_activity(:deployment).save

    true
  rescue
    false
  end
end