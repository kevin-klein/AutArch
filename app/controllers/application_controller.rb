class ApplicationController < ActionController::Base
  include Pagy::Backend
  skip_forgery_protection
end
