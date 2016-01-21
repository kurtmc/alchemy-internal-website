class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    # restrict access to admin module for non-admin users
    def authenticate_admin_user!
        if current_user.nil?
            raise SecurityError
            return
        end
        unless current_user.admin == true
            raise SecurityError
            return
        end
    end

    rescue_from SecurityError do |exception|
        redirect_to root_url
    end
end
