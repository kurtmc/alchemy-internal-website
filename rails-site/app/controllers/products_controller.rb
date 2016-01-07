require 'rubygems'
require 'csv'

class ProductsController < ApplicationController
    def index
        products_csv = get_product_csv
        prods = Array.new
        products_csv.each { |x|
            prods << new_product(x)
        }
        @products = prods
    end

    def show
        @product = find_product(params[:id])
    end

    private

    def new_product(csv_entry)
        return Product.new(product_id:csv_entry[0], description:csv_entry[4])
    end
    
    def get_product_csv
        products_csv_path = Rails.root.join('alchemy-info-tables', 'gen', 'NZ_ID_SDS_PDS_VENDOR_NAME.csv')
        products_csv = CSV.read(products_csv_path)
        titles = products_csv.shift
        return products_csv
    end

    def find_product(product_id)
        products_csv = get_product_csv
        products_csv.each { |x|
            if x[0] == params[:id] then
                return new_product(x)
            end
        }
        return nil
    end
end
