module AppHelper
  def app_dir(app)
    Pathname.new(Rails.configuration.apps_dir).join(app.subdomain)
  end
end