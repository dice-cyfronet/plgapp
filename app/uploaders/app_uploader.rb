class AppUploader < CarrierWave::Uploader::Base
  storage :app

  def store_dir
    model.dev_subdomain
  end

  def root
    Rails.configuration.apps_dir
  end

  def extension_white_list
    %w(zip)
  end
end
