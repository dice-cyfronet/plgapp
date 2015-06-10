class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can [:read, :download, :activity],
        App, app_members: { user_id: user.id }

    can [:edit, :update, :destroy, :deploy, :push],
        App, app_members: { user_id: user.id, role: 'master' }

    can :deploy, App, app_members: { user_id: user.id, role: 'developer' }

    can [:create], App unless user.new_record?

    can :view, App
    can :dev_view, App, app_members: { user_id: user.id }
  end
end
