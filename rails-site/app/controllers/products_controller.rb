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

    def edit
        @product = find_product(params[:id])
    end

    def download_sds
          prod = find_product(params[:id])
          info_path = 'alchemy-info-tables/res/Product_Information/' + prod.directory
          unless prod.sds.nil?
            download_pdf(info_path, prod.sds)
          end
    end

    def download_pds
          prod = find_product(params[:id])
          info_path = 'alchemy-info-tables/res/Product_Information/' + prod.directory
          unless prod.pds.nil?
            download_pdf(info_path, prod.pds)
          end
    end

    private

    def download_pdf(directory, filename)
        send_file(Rails.root.join(directory, filename), filename: filename, type: "application/pdf")
    end

    def new_product(csv_entry)
        prod = Product.new
        prod.product_id = csv_entry[0]
        prod.directory = csv_entry[1]
        prod.sds = csv_entry[2]
        prod.pds = csv_entry[3]
        prod.description = csv_entry[4]
        prod.vendor_id = csv_entry[5]
        prod.vendor_name = csv_entry[6]
        puts "#{prod.product_id}, #{prod.description}, #{prod.sds} "
        return prod
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
