class Api::CustomerUsersController < Api::ApiController

    def index
        @customer_users = CustomerUser.all
        respond_to do |format|
            format.json {
                if params[:csv] == 'true'
                    if params[:product_relation] == 'true'
                        render text: get_product_relation_csv
                    else
                        render text: get_customer_users_csv
                    end
                else
                    render json: @customer_users
                end
            }
        end
    end

    def get_product_relation_csv
        sql = 'select * from customer_users_products'
        mapping = Hash.new
        mapping['customer_user_id'] = 'customer_user_id'
        mapping['product_id'] = 'product_id'
        csv_string = CSV.generate do |csv|
            csv << mapping.values
            all = ActiveRecord::Base.connection.execute(sql)
            all.each do |v|
                csv << [v['customer_user_id'], v['product_id']]
            end
        end
    end

    def get_customer_users_csv
        mapping = Hash.new
        mapping['id'] = 'id'
        mapping['email'] = 'email'
        mapping['password'] = 'password'

        csv_string = CSV.generate do |csv|
            csv << mapping.values
            all = CustomerUser.select(mapping.keys)
            all.each do |cust|
                csv << cust.attributes.values
            end
        end
    end

end
