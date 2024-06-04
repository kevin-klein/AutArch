class UserSessionsController < ApplicationController
  layout "user_sessions"

  def login
  end

  def login_code
    user = User.find(params[:login][:user_id])

    if user.code_hash == params[:login][:code]
      session[:user_id] = user.id
      redirect_to "/", notice: "Successfully logged in"
    else
      flash[:notice] = "The code you entered was not correct."
      redirect_to "/login"
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to "/"
  end

  def code
    email = params[:login][:email]
    @user = User.find_by(email: email)

    if @user.nil?
      raise
    else
      User.transaction do
        @user.code_hash = SecureRandom.alphanumeric(6)
        @user.save!
      end

      LoginMailer.with(user: @user).login_code.deliver_later
    end
  end
end
