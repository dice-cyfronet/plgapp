class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can [:read, :create, :edit, :update, :destroy], App, author_id: user.id
  end
end
