module Dropbox
  class MoveService < Operation
    protected

    def initialize(author, from, to, options = {})
      super(author, nil, options)
      @from = from
      @to = to
    end

    def internal_execute
      client.file_move(@from, @to) if path_changed?
    rescue DropboxError
      # source dir does not exist - do nothing
    end

    private

    def path_changed?
      @from != @to
    end
  end
end
