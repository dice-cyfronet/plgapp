require 'rails_helper'

RSpec.describe CarrierWave::Storage::App do


  it 'checks for directory traversal attack vulnerability' do
    Dir.mktmpdir do |dir|
      attack_path = "/tmp/zip-attack.gif"

      FileUtils.rm_rf(attack_path)

      file = double(:file)
      zip = Rails.root.join('spec', 'resources', 'directory-traversal-attack.zip')

      expect(file).to receive(:file).and_return(zip)

      uploader = double(:uploader)

      expect(uploader).to receive(:store_dir).and_return(File.basename(dir))
      expect(uploader).to receive(:root).and_return(File.dirname(dir))

      app = CarrierWave::Storage::App.new(uploader)
      app.store!(file)

      expect(File.exist?(attack_path)).to be false

      FileUtils.rm_rf(attack_path)
    end
  end


end