class ApplicationController < ActionController::Base
  include PublicActivity::StoreController
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
  	stored_location_for(resource) || user_root_path(current_user)
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
    		u.permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
    	end
    	devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(:username, :first_name, :last_name, :date_of_birth, :sex, :bio, :city, :avatar, :email, :password, :password_confirmation, :current_password)
    	end
    end
end