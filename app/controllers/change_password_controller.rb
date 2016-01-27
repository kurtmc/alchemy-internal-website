class ChangePasswordController < ApplicationController
    def index
    end

    def create
        password = params[:user][:password]
        same = password == params[:user][:confirm_password]
        password_length = User.password_length.include? password.length
        if same && password_length
            current_user.password = password
            current_user.save
            @message = "Password successfully changed!"
            render :index
        else
            unless same
                @message = "Passwords do not match, therefore the password was not changed!"
            end
            unless password_length
                first = User.password_length.first
                last = User.password_length.last
                @message = "Password must be between #{first} and #{last} characters long inclusive, therefore the password was not changed!"
            end
            render :index
        end
    end
end
