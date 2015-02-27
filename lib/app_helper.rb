module AppHelper
  def app_dir(app)
    subdomain = app.respond_to?(:subdomain) ? app.subdomain : app
    Pathname.new(Rails.configuration.apps_dir).join(subdomain)
  end
end