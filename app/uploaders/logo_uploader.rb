# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  resize_to_limit(1100, 200)

  version :thumb do
    resize_to_limit(350, 133)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
