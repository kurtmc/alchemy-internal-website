class CustomersController < ApplicationController
    def index
        @customers = Customer.all
    end

    def show
        @customer = Customer.find_by customer_id: params[:id]
    end
end
