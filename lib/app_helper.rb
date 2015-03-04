module AppHelper
  def app_dir(app, postfix = '')
    subdomain = app.respond_to?(:subdomain) ? app.subdomain : app
    Pathname.new(Rails.configuration.apps_dir).join("#{subdomain}#{postfix}")
  end

  def app_dev_dir(app)
    app_dir(app, Rails.configuration.dev_postfix)
  end
end
