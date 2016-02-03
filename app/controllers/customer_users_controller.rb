class CustomerUsersController < InheritedResources::Base

    def new
        @products = Product.all
    end

    def edit
        @products = Product.all
        @customer_user = CustomerUser.find(params[:id])
    end

    def show
        @customer_user = CustomerUser.find(params[:id])
        @products = @customer_user.products
    end

    def update
        @customer_user = CustomerUser.find(params[:id])
        @customer_user.email = params[:customer_user][:email]
        @customer_user.password = params[:customer_user][:password]
        params[:customer_user][:products].each { |p|
            unless p == ''
                product = Product.find(p)
                @customer_user.products << product
            end
        }
        @customer_user.save
        render 'show'
    end

  private

    def customer_user_params
      params.require(:customer_user).permit(:email, :password)
    end
end

