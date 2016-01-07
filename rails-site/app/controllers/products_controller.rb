require 'rubygems'
require 'csv'

class ProductsController < ApplicationController
    def index
        products_csv_path = Rails.root.join('alchemy-info-tables', 'gen', 'NZ_ID_SDS_PDS_VENDOR_NAME.csv')
        products_csv = CSV.read(products_csv_path)
        titles = products_csv.shift
        prods = Array.new
        products_csv.each { |x|
            prods << Product.new(product_id:x[0], description:x[4])
        }
        @products = prods
    end
end
