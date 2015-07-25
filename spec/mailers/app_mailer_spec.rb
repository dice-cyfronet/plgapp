require 'rails_helper'

RSpec.describe AppMailer do
  it 'send disconnect from dropbox email with correct locale' do
    user = build(:user, locale: 'pl')

    mail = AppMailer.dropbox_disconnect_email(user)

    expect(mail.subject).to include 'Rozłączenie'
  end
end
