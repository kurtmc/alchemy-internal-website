class Api::ProductsController < ActionController::Base
    def authenticate_json_user!
        user = User.find_by_email(params[:user][:email])
        unless user.valid_password?(params[:user][:password])
            raise SecurityError
        end
    end

    before_filter :authenticate_json_user!

    def index
        @products = Product.all.order :product_id
        respond_to do |format|
            format.json {
                if params[:csv] == 'true'
                    csv_string = CSV.generate do |csv|
                        csv << Product.attribute_names
                        Product.all.each do |product|
                            csv << product.attributes.values
                        end
                    end
                    render text: csv_string
                else
                    render json: @products
                end
            }
        end
    end

    def show
        respond_to do |format|
            format.json { render json: Product.find(params[:id])}
        end
    end
end
