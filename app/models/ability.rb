class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can [:read, :download, :activity],
        App, app_members: { user_id: user.id }

    can [:edit, :update, :destroy, :deploy, :push],
        App, app_members: { user_id: user.id, role: 'master' }

    can :deploy, App, app_members: { user_id: user.id, role: 'developer' }

    can :index, AppMember, user_id: user.id
    can [:new, :create, :edit, :update, :destroy, :show],
        AppMember do |app_member|
      user_membership = AppMember.find_by(user_id: user.id,
                                          app_id: app_member.app_id)

      user_membership != app_member && user_membership.try(:master?)
    end

    can [:create], App unless user.new_record?

    can :view, App
    can :dev_view, App, app_members: { user_id: user.id }
  end
end
