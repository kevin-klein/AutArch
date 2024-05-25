class LoginMailer < ApplicationMailer
  def login_code
    @user = params[:user]
    mail(to: @user.email, subject: "AutArch Login Code")
  end
end
