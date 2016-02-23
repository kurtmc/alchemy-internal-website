class CustomerUsersController < InheritedResources::Base

    def new
        @products = Product.all
        @customer_user = CustomerUser.new
        o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
        @random_password = (0...12).map { o[rand(o.length)] }.join
    end

    def edit
        @products = Product.all
        @customer_user = CustomerUser.find(params[:id])
    end

    def show
        @customer_user = CustomerUser.find(params[:id])
        @products = @customer_user.products
        @body = "Login with you email

email: #{@customer_user.email}
password: #{@customer_user.password}"
    end

    def update
        @customer_user = CustomerUser.find(params[:id])
        update_fields
        redirect_to @customer_user
    end

    def create
        @customer_user = CustomerUser.new
        update_fields
        redirect_to @customer_user
    end

  private

    def customer_user_params
      params.require(:customer_user).permit(:email, :password)
    end

    def update_fields
        @customer_user.email = params[:customer_user][:email]
        @customer_user.password = params[:customer_user][:password]
        @customer_user.products.delete_all
        if params[:all_products] == '1'
            @customer_user.products = Product.all
            @customer_user.save
            return
        end
        if params[:customer_user][:products].nil?
            @customer_user.save
            return
        end
        params[:customer_user][:products].each { |p|
            unless p == ''
                product = Product.find(p)
                @customer_user.products << product
            end
        }
        @customer_user.save
    end
end

