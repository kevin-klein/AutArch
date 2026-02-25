class ApplicationController < ActionController::Base
  include Pagy::Method

  skip_forgery_protection

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
    if Rails.env.development?
      @current_user = User.find(1)
    end

    if @current_user&.disabled?
      @current_user = nil
    end

    @current_user
  end

  rescue_from CanCan::AccessDenied do |exception|
    # Store the exception message for the view
    flash[:alert] = "You don't have permission to #{exception.action} this #{exception.subject.class.name.downcase}."

    # Redirect to the home page or previous page
    redirect_to(request.referrer || root_path)
  end
end
