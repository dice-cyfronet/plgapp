module Dropbox
  class PullService < Operation
    def execute
      changes = calculate_changes

      create_or_update(changes[:create] + changes[:update])
      delete(changes[:delete])
    end

    private

    def create_or_update(to_create)
      to_create.each do |entry|
        path, entry_hsh = entry
        if entry_hsh['is_dir']
          create_update_dir(entry_hsh)
        else
          download_file(entry_hsh)
        end
      end
    end

    def create_update_dir(entry_hsh)
      relative_path = remote_to_relative(entry_hsh['path'])
      dest_path = relative_to_local(relative_path)

      FileUtils.mkdir_p(dest_path) unless File.exist?(dest_path)
      app_member.dropbox_entries.
        find_or_initialize_by(path: relative_path).tap do |entry|
          entry.is_dir = true
          entry.revision = entry_hsh['rev']
        end.
        save
    end

    def download_file(entry_hsh)
      tmp = new_tmp_path
      File.open(tmp, "wb") do |f|
        f << client.get_file(entry_hsh['path'])
      end
      relative_path = remote_to_relative(entry_hsh['path'])
      dest_path = relative_to_local(relative_path)
      dest_dir = Pathname.new(dest_path).dirname
      FileUtils.mkdir_p(dest_dir) unless File.exist?(dest_dir)
      FileUtils.mv(tmp, dest_path)

      app_member.dropbox_entries.
        find_or_initialize_by(path: relative_path).tap do |entry|
          entry.is_dir = false
          entry.local_hash = calculate_hash(dest_path)
          entry.revision = entry_hsh['rev']
        end.save!
    end

    def new_tmp_path
      tmp = Tempfile.new('plgapp')
      tmp_path = tmp.path
      tmp.unlink
    end

    def delete(to_delete)
      to_delete.each do |entry|
        path = relative_to_local(entry.path)
        FileUtils.rm_rf(path) if File.exist?(path)
        entry.destroy
      end
    end

    def calculate_changes
      changes = { create: [], update: [], delete: [] }

      delta['entries'].each do |entry|
        path, revision = entry
        existing_entry = entry(remote_to_relative(path))

        if revision
          changes[existing_entry ? :update : :create] << entry
        else
          changes[:delete] << existing_entry if existing_entry
        end
      end

      changes
    end

    def remote_to_relative(path)
      @subdomain_count ||= app.subdomain.length + 2
      path[@subdomain_count..-1]
    end

    def delta
      client.delta(cursor, File.join('/', app.subdomain))
    end

    def cursor
      app_member.dropbox_cursor
    end
  end
end
