require 'app_helper'

class AppService
  include AppHelper

  def initialize(author, app)
    @author = author
    @app = app
  end

  protected

  attr_reader :author, :app

  def build_activity(type)
    app.activities.build(author: author, activity_type: type)
  end
end
