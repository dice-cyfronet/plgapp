require 'dropbox_sdk'

module Dropbox
  class PushService < Operation
    def execute
      changes = calculate_changes

      create(changes[:create])
      update(changes[:update])
      delete(changes[:delete])
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
      changes = { create: [], update: [] }

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
          is_dir: File.directory?(local_path),
          local_hash: calculate_hash(local_path)
        }

        if entry = snapshot[p]
          if modified?(entry_hsh, entry)
            changes[:update] << entry_hsh
          end
        else
          changes[:create] << entry_hsh
        end
      end

      changes[:delete] = snapshot.
        reject { |k, _| list_local.include?(k) || k == '.' }.values

      changes
    end

    def modified?(entry_hsh, entry)
      !entry_hsh[:is_dir] && entry_hsh[:local_hash] != entry.local_hash
    end

    def list_local
      @list_local ||= Dir.chdir(root_path) { Dir.glob('**/**') }.sort
    end

    def create_client
      DropboxClient.new(author.dropbox_access_token)
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
      File.open(entry_hsh[:local_path], "r") do |f|
        entry = snapshot[entry_hsh[:path]] ||
                  entries.build(path: entry_hsh[:path])

        metadata = client.put_file(entry_hsh[:remote_path], f,
                                   false, entry[:revision])

        entry.is_dir = false
        entry.local_hash = entry_hsh[:local_hash]
        entry.revision = metadata['rev']

        entry.save
      end
    end
  end
end
