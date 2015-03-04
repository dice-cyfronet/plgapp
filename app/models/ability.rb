class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can [:read, :edit, :update, :destroy,
         :download, :deploy, :activity, :push],
        App, app_members: { user_id: user.id }

    can [:create], App unless user.new_record?

    can :view, App
    can :dev_view, App, app_members: { user_id: user.id }
  end
end
