module Dropbox
  class MoveService < Operation
    protected

    def internal_execute
      from = app.old_subdomain
      to = app.subdomain

      client.file_move(from, to) if from != to
    end
  end
end
