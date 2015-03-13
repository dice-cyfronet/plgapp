require 'dropbox_sdk'

module Dropbox
  class PushService < AppService
    def initialize(author, app, options = {})
      super(author, app)
      @app_member = app.app_members.find_by(user: author)
      @client = options.fetch(:client) { create_client }
    end

    def execute
      changes = calculate_changes

      create(changes[:create])
      update(changes[:update])
    end

    private

    attr_reader :client, :app_member

    def create(to_create)
      to_create.each do |entry|
        if entry[:is_dir]
          create_dir(entry)
        else
          put_file(entry)
        end
      end
    end

    def update(to_update)
      to_update.each { |entry| put_file(entry) }
    end

    def registered?
      app_member.dropbox_entries.where(path: '.', is_dir: true).count > 0
    end

    def calculate_changes
      changes = { create: [], update: [], delete: [] }
      unless registered?
        changes[:create] << {
          path: '.',
          is_dir: true,
          remote_path: relative_to_remote('.')
        }
      end

      list_local.each do |p|
        local_path = relative_to_local(p)
        entry_hsh = {
          path: p,
          local_path: local_path,
          remote_path: relative_to_remote(p),
          modified: File.mtime(local_path),
          is_dir: File.directory?(local_path),
          local_hash: calculate_hash(local_path)
        }

        if entry = snapshot[p]
          if modified?(entry_hsh, entry)
            entry_hsh[:entry] = entry
            changes[:update] << entry_hsh
          end
        else
          changes[:create] << entry_hsh
        end
      end

      changes
    end

    def modified?(entry_hsh, entry)
      !entry_hsh[:is_dir] && entry_hsh[:local_hash] != entry.local_hash
    end

    def list_local
      Dir.chdir(root_path) { Dir.glob('**/**') }.sort
    end

    def snapshot
      @snapshot = snapshot_hsh
    end

    def snapshot_hsh
      app_member.dropbox_entries.each_with_object({}) { |v, h| h[v.path] = v }
    end

    def root_path
      @root_path ||= app_dev_dir(app)
    end

    def create_client
      DropboxClient.new(author.dropbox_access_token)
    end

    def create_dir(entry)
      client.file_create_folder(entry[:remote_path])
      entries.create(path: entry[:path], is_dir: true)
    end

    def put_file(entry_hsh)
      File.open(entry_hsh[:local_path], "r") do |f|
        entry = entries.find_or_initialize_by(path: entry_hsh[:path])

        metadata = client.put_file(entry_hsh[:remote_path], f,
                                   false, entry[:revision])

        puts "metadata #{metadata}"

        entry.is_dir = false
        entry.local_hash = entry_hsh[:local_hash]
        entry.modified = entry_hsh[:modified]
        entry.revision = metadata['rev']

        entry.save
      end
    end

    def entries
      app_member.dropbox_entries
    end

    def relative_to_local(path)
      Pathname.new(root_path).join(path)
    end

    def relative_to_remote(path)
      Pathname.new('/').join(app.subdomain, path).to_s
    end

    def calculate_hash(filepath)
      begin
        Digest::MD5.file(filepath).to_s
      rescue Errno::EISDIR
        nil
      rescue Errno::ENOENT
        nil
      end
    end
  end
end
