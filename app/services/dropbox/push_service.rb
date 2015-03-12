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
    end

    private

    attr_reader :client, :app_member

    def create(to_create)
      to_create.each do |p|
        local_path = relative_to_local(p)
        File.directory?(local_path) ? create_dir(p) : put_file(p, local_path)
      end
    end

    def registered?
      app_member.dropbox_entries.where(path: '.', is_dir: true).count > 0
    end

    def calculate_changes
      changes = { create: [], update: [], delete: [] }
      changes[:create] << '.' unless registered?

      list_local.each do |p|
        if entry = snapshot[p]
          changes[:update] << p
        else
          changes[:create] << p
        end
      end

      changes
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

    def relative_to_local(path)
      Pathname.new(root_path).join(path)
    end

    def create_client
      DropboxClient.new(author.dropbox_access_token)
    end

    def create_dir(path)
      client.file_create_folder(remote_path(path))
      entries.create(path: path, is_dir: true)
    end

    def put_file(path, local_path, previous_revision = nil)
      File.open(local_path, "r") do |f|
        client.put_file(remote_path(path), f, false, previous_revision)
        entries.create(path: path, is_dir: false)
      end
    end

    def entries
      app_member.dropbox_entries
    end

    def remote_path(path)
      Pathname.new('/').join(app.subdomain, path).to_s
    end
  end
end
