class Api::ApiController < ActionController::Base
    def authenticate_json_user!
        user = User.find_by_email(params[:user][:email])
        unless user.valid_password?(params[:user][:password]) && user.api_user?
            raise SecurityError
        end
    end

    before_filter :authenticate_json_user!
end
