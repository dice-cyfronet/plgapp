require 'zip'

module CarrierWave
  module Storage
    class App < Abstract
      def store!(file)
        tmp_dir = Dir.mktmpdir('plgapp')
        Zip::File.open(file.file) do |zipfile|
          zipfile.each do |f|
            unless f.symlink?
              dest_file = ::File.expand_path(f.name, tmp_dir)
              f.extract(dest_file)
            end
          end

          FileUtils.rm_r(app_dir)
          FileUtils.mv(tmp_dir, app_dir)
        end
      end

      def retrieve!(_identifier)
        AppZipFile.new(app_dir)
      end

      private

      def app_dir
        @app_dir ||= ::File.expand_path(uploader.store_dir, uploader.root)
      end
    end

    class AppZipFile
      def initialize(app_dir)
        @app_dir = app_dir
      end

      def path
        file.path
      end

      def delete
        # do nothing since upload will override app dir
      end

      def file
        @file ||= zip_file
      end

      private

      def zip_file
        path = tmp_file_path
        Zip::File.open(path, Zip::File::CREATE) do |zf|
          app_files.each do |app_file|
            zip_path = Pathname.new(app_file).relative_path_from(app_dir)
            zf.add(zip_path, app_file)
          end
        end

        ::File.new(path)
      end

      def tmp_file_path
        t = Time.now.strftime('%Y%m%d')
        filename = "#{app_dir.basename}-#{t}-#{rand(0x100000000).to_s(36)}.zip"

        ::File.join(Dir.tmpdir, filename)
      end

      def app_dir
        Pathname.new(@app_dir)
      end

      def app_files
        Dir.glob("#{@app_dir}/**/*").select { |e| ::File.file?(e) }
      end
    end
  end
end
