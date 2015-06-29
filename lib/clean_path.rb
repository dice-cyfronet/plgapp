module CleanPath
  VALID_CHARACTERS = "a-zA-Z0-9~!@$%^&*()#`_+-=<>\"{}|[];',?".freeze

  def clean_path(path)
    valid_chars_path = (path || '').tr("^#{VALID_CHARACTERS}", '')
    Pathname.new("/#{valid_chars_path}").cleanpath.to_s[1..-1]
  end
end
