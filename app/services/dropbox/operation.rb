require 'dropbox_sdk'
require 'clean_path'

module Dropbox
  class Operation < AppService
    include CleanPath

    def initialize(author, app, options = {})
      super(author, app)
      @app_member = app && app.app_members.find_by(user: author)
      @client = options.fetch(:client) { create_client }
    end

    def execute
      internal_execute
    rescue DropboxAuthError
      Rails.logger.warn(I18n.t('dropbox_auth_error', user: @author.login))
      Dropbox::DisableJob.perform_later(@author)
    end

    protected

    def internal_execute
      railse 'need to be implemented in descendent class'
    end

    attr_reader :client, :app_member

    def root_path
      @root_path ||= app_dev_dir(app)
    end

    def create_client
      DropboxClient.new(author.dropbox_access_token)
    end

    def entry(path)
      snapshot[path]
    end

    def entries
      app_member.dropbox_entries
    end

    def snapshot
      @snapshot = app_member.
                  dropbox_entries.
                  each_with_object({}) { |v, h| h[v.path] = v }
    end

    def relative_to_local(path)
      File.join(root_path, clean_path(path))
    end

    def relative_to_remote(path)
      Pathname.new('/').join(app.subdomain, path).to_s
    end

    def calculate_hash(filepath)
      Digest::MD5.file(filepath).to_s
    rescue Errno::EISDIR
      nil
    rescue Errno::ENOENT
      nil
    end
  end
end
