class ApplicationMailer < ActionMailer::Base
  default from: ENV['EMAIL_USERNAME']
  layout "mailer"
end
