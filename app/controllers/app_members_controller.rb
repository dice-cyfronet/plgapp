class AppMembersController < ApplicationController
  load_and_authorize_resource :app, find_by: :subdomain
  before_action :load_app_members, only: :index
  load_and_authorize_resource :app_member, through: :app

  before_filter :set_apps, only: :index

  def index
  end

  def show
    render partial: 'app_member', locals: { app_member: @app_member }
  end

  def new
    render partial: 'new'
  end

  def create
    if @app_member.save
      show
    else
      render partial: 'new'
    end
  end

  def edit
    render partial: 'edit'
  end

  def update
    if @app_member.update_attributes(update_params)
      render partial: 'app_member', locals: { app_member: @app_member }
    else
      render partial: 'edit'
    end
  end

  def destroy
    @app_member.destroy!
    head :ok
  end

  private

  def set_apps
    @apps = App.accessible_by(current_ability)
  end

  def load_app_members
    @app_members = AppMember.where(app: @app)
  end

  def create_params
    params.require(:app_member).permit(:user_id, :role)
  end

  def update_params
    params.require(:app_member).permit(:role)
  end
end
