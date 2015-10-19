module Dropbox
  class MoveService < Operation
    protected

    def initialize(author, from, to, options = {})
      super(author, nil, options)
      @from = from
      @to = to
    end

    protected

    def internal_execute
      client.file_move(@from, @to) if path_changed?
    rescue DropboxError => e
      raise e unless e.http_response.class == Net::HTTPNotFound
    end

    private

    def path_changed?
      @from != @to
    end
  end
end
