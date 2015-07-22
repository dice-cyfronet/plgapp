class AppMailer < ApplicationMailer
  def dropbox_disconnect_email(user)
    @user = user
    @from = AppMailer.default[:from]
    mail(to: @user.email,
         subject: I18n.t('email.dropbox_disconnected.subject'))
  end
end
