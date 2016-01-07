require 'rubygems'
require 'csv'

class ProductsController < ApplicationController
    def index
        products_csv = get_product_csv
        prods = Array.new
        products_csv.each { |x|
            prods << Product.new(product_id:x[0], description:x[4])
        }
        @products = prods
    end

    def show
        products_csv = get_product_csv
        products_csv.each { |x|
            if x[0] == params[:id] then
                @product = Product.new(product_id:x[0], description:x[4])
                return
            end
        }
    end

    private
    
    def get_product_csv
        products_csv_path = Rails.root.join('alchemy-info-tables', 'gen', 'NZ_ID_SDS_PDS_VENDOR_NAME.csv')
        products_csv = CSV.read(products_csv_path)
        titles = products_csv.shift
        return products_csv
    end
end
