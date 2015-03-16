module DropboxHelper
  # expect app_member method
  def dir_entries(*paths)
    paths.each do |path|
      app_member.dropbox_entries.create!(path: path, is_dir: true)
    end
  end

  # expect app_member method
  def file_entry(path, revision = nil, hash = nil)
    app_member.dropbox_entries.
      create!(path: path, is_dir: false, revision: revision, local_hash: hash)
  end

  # expect app_member method
  def entry(path)
    app_member.dropbox_entries.find_by!(path: path)
  end
end
