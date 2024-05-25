class ApplicationController < ActionController::Base
  include Pagy::Backend
  skip_forgery_protection

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
