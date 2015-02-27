require 'carrierwave/storage/app'

CarrierWave.configure do |config|
  config.storage_engines.merge!(app: 'CarrierWave::Storage::App')
  config.cache_dir = Pathname.new(Dir.tmpdir).join('plgapp', 'uploads')
end
