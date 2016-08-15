class Api::CustomerUsersController < Api::ApiController

    def index
        customer_users = CustomerUser.all
        respond_to do |format|
            format.json {
                render :json => customer_users, :include => {:products => {:only => :id}}
            }
        end
    end

    def show
        @customer_user = CustomerUser.find(params[:id])

        respond_to do |format|
            format.json {
                render :json => @customer_user
            }
        end
    end

    def get_by_email
        @customer_user = CustomerUser.find_by email: params[:email]

        respond_to do |format|
            format.json {
                render :json => @customer_user
            }
        end
    end

    def update
        @customer_user = CustomerUser.find(params[:id])
        
        terms = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:terms_of_use])
        if terms
            @customer_user.terms_of_use = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:terms_of_use]) 
            @customer_user.save
        end

        unless params[:password].blank?
            @customer_user.password = params[:password]
            @customer_user.save
        end
        respond_to do |format|
            format.json {
                render :json => @customer_user
            }
        end
    end

end
