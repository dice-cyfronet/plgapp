module Dropbox
  class PullService < Operation
    protected

    def internal_execute
      changes = calculate_changes

      create_or_update(changes[:create_or_update])
      delete(changes[:delete])

      app_member.update_attributes(dropbox_cursor: delta['cursor'])

      changed?(changes)
    end

    private

    def changed?(changes)
      (changes[:delete].length + changes[:create_or_update].length) > 0
    end

    def create_or_update(to_create)
      to_create.
        select { |p| p[:path].present? }.
        each do |props|
          props[:is_dir] ? create_update_dir(props) : create_update_file(props)
        end
    end

    def create_update_dir(props)
      FileUtils.mkdir_p(props[:local_path])
      update_entry(props[:path], is_dir: true, revision: props[:revision])
    end

    def create_update_file(props)
      download_file(props)
      update_entry(props[:path],
                   is_dir: false,
                   local_hash: calculate_hash(props[:local_path]),
                   revision: props[:revision])
    end

    def update_entry(path, attrs = {})
      app_member.dropbox_entries.
        find_or_initialize_by(path: path).tap do |entry|
          entry.assign_attributes(attrs)
        end.save!
    end

    def download_file(props)
      tmp = File.open(new_tmp_path, 'wb') do |f|
        f << client.get_file(props[:remote_path])
      end
      mv(tmp.path, props[:local_path])
    end

    def new_tmp_path
      Tempfile.open('plgapp') { |f| f.path }
    end

    # move and create dir if missing
    def mv(source, target)
      dest_dir = Pathname.new(target).dirname
      FileUtils.mkdir_p(dest_dir) unless File.exist?(dest_dir)
      FileUtils.mv(source, target)
    end

    def delete(to_delete)
      to_delete.each do |entry|
        local_path = relative_to_local(entry.path)
        FileUtils.rm_rf(local_path) if File.exist?(local_path)
        entry.destroy
      end
    end

    def calculate_changes
      { create_or_update: [], delete: [] }.tap do |changes|
        delta['entries'].each do |entry|
          path, entry_hsh = entry
          existing_entry = entry(remote_to_relative(path))

          if entry_hsh.blank?
            changes[:delete] << existing_entry if existing_entry
          elsif modified?(existing_entry, entry_hsh)
            changes[:create_or_update] << remote_props(entry_hsh)
          end
        end
      end
    end

    def remote_props(entry_hsh)
      path = remote_to_relative(entry_hsh['path'])
      {
        path: path,
        local_path: relative_to_local(path),
        remote_path: entry_hsh['path'],
        revision: entry_hsh['rev'],
        size: entry_hsh['bytes'],
        is_dir: entry_hsh['is_dir']
      }
    end

    def modified?(existing_entry, entry_hsh)
      existing_entry.blank? ||
        existing_entry.revision != entry_hsh['rev']
    end

    def remote_to_relative(path)
      @subdomain_count ||= app.subdomain.length + 2
      clean_path(path[@subdomain_count..-1] || '.')
    end

    def delta
      @delta ||= client.delta(cursor, File.join('/', app.subdomain))
    end

    def cursor
      app_member.dropbox_cursor
    end
  end
end
