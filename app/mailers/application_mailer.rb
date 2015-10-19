class ApplicationMailer < ActionMailer::Base
  default from: ENV['EMAIL_USERNAME'] || 'plgapp@plgrid.pl'
  layout 'mailer'
end
