class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can [:read, :edit, :update, :destroy, :download, :deploy, :activity], App,
        app_members: { user_id: user.id }

    can [:create], App unless user.new_record?
  end
end
