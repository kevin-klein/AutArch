class ApplicationController < ActionController::Base
  include Pagy::Method
  skip_forgery_protection

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
    if Rails.env.development?
      @current_user = User.find(1)
    end

    if @current_user && @current_user.disabled?
      @current_user = nil
    end

    @current_user
  end
end
