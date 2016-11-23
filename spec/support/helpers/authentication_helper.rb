module AuthenticationHelper
  def sign_in_as(user)
    stub_oauth(
      :open_id,
      nickname: user.login,
      name: user.name,
      email: user.email
    )
    visit root_path
    find(:linkhref, user_open_id_omniauth_authorize_path).click
  end

  def sign_in_as_admin
    create(:user, admin: true).tap { |admin| sign_in_as(admin) }
  end
end
