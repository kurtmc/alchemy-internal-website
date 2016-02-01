class Api::CustomerUsersController < Api::ApiController

    def index
        @customer_users = CustomerUser.all
        respond_to do |format|
            format.json {
                if params[:csv] == 'true'
                    render text: get_customer_users_csv
                else
                    render json: @customer_users
                end
            }
        end
    end

    def get_customer_users_csv
        mapping = Hash.new
        mapping['id'] = 'id'
        mapping['email'] = 'email'
        mapping['password'] = 'password'
        mapping['product_ids'] = 'products'
        
        csv_string = CSV.generate do |csv|
            csv << mapping.values
            all = CustomerUser.select(mapping.keys)
            all.each do |cust|
                csv << cust.attributes.values
            end
        end
    end

end
