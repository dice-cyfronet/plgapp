require 'dropbox_sdk'

module Dropbox
  class PushService < Operation
    protected

    def internal_execute
      changes = calculate_changes

      create(changes[:create])
      update(changes[:update])
      delete(changes[:delete])
    end

    private

    def create(to_create)
      to_create.each do |entry|
        entry[:is_dir] ? create_dir(entry) : put_file(entry)
      end
    end

    def update(to_update)
      to_update.each { |entry| put_file(entry) }
    end

    def delete(to_delete)
      to_delete.each do |e|
        delete_path(e.path)
        e.destroy
      end
    end

    def registered?
      !entry('.').blank?
    end

    def calculate_changes
      { create: [], update: [] }.tap do |changes|
        changes[:create] << local_props('.') unless registered?

        list_local.each do |p|
          local_props = local_props(p)
          entry = snapshot[p]

          if entry.blank?
            changes[:create] << local_props
          elsif modified?(local_props, entry)
            changes[:update] << local_props
          end
        end

        changes[:delete] = calculate_delete_changes
      end
    end

    def local_props(path)
      local_path = relative_to_local(path)
      {
        path: path,
        local_path: local_path,
        remote_path: relative_to_remote(path),
        is_dir: File.directory?(local_path)
      }.tap do |props|
        props[:local_hash] = calculate_hash(local_path) unless props[:is_dir]
      end
    end

    def calculate_delete_changes
      snapshot.reject { |k, _| list_local.include?(k) || k == '.' }.values
    end

    def modified?(props, entry)
      !props[:is_dir] && props[:local_hash] != entry.local_hash
    end

    def list_local
      @list_local ||= Dir.chdir(root_path) { Dir.glob('**/**') }.sort
    end

    def create_dir(entry)
      client.file_create_folder(entry[:remote_path])
      entries.create(path: entry[:path], is_dir: true)
    end

    def delete_path(path)
      remote_path = relative_to_remote(path)
      client.file_delete(remote_path)
      snapshot[path].destroy
    rescue DropboxError => e
      raise e unless e.http_response.class == Net::HTTPNotFound
    end

    def put_file(entry_hsh)
      File.open(entry_hsh[:local_path], 'r') do |f|
        entry = get_or_build_entry(entry_hsh[:path])

        metadata = client.put_file(entry_hsh[:remote_path], f,
                                   false, entry[:revision])

        entry.is_dir = false
        entry.local_hash = entry_hsh[:local_hash]
        entry.revision = metadata['rev']

        entry.save
      end
    end

    def get_or_build_entry(path)
      snapshot[path] || entries.build(path: path)
    end
  end
end
