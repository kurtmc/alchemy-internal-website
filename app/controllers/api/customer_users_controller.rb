class Api::CustomerUsersController < Api::ApiController

    def index
        @customer_users = CustomerUser.all
        respond_to do |format|
            format.json {
                render :json => @customer_users, :include => {:products => {:only => :id}}
            }
        end
    end

end
