module AuthenticationHelper
  def sign_in_as(user)
    stub_oauth(
      :open_id,
      nickname: user.login,
      name: user.name,
      email: user.email
    )
    visit root_path
    find(:linkhref, user_omniauth_authorize_path(:open_id)).click
  end
end
