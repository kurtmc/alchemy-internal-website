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
            format.json { render json: @products}
        end
    end

    def show
        respond_to do |format|
            format.json { render json: Product.find(params[:id])}
        end
    end
end
