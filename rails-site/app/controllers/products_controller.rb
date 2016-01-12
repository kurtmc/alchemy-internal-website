require 'rubygems'
require 'csv'
require 'uri'

class ProductsController < ApplicationController
    def index
        @products = get_products
    end

    def show
        @product = find_product(params[:id])
    end

    def edit
        @product = find_product(params[:id])
    end

    def handle_upload(uploaded_io, file_type)
        unless ['sds', 'pds', 'coa'].include? file_type.downcase
            return
        end

        new_filename = uploaded_io.original_filename
            old_filename = nil
            start = "#{file_type.upcase} - "
            field = file_type.upcase
            old_filename = @product[field.downcase]

            unless new_filename.start_with?(start)
                @product.errors.add("#{field}_filename", "\"#{new_filename}\" does not begin with \"#{start}\"")
                return
            end

            path = "alchemy-info-tables/res/Product_Information"
            path = path + "/#{@product.directory}"

            # First delete old file
            unless old_filename.nil?
                File.delete(Rails.root.join(path, old_filename))
            end
            
            # Write new file
            write_uploaded_file(path, uploaded_io)

            regen_tables
            
            @product[field.downcase] = new_filename
    end

    def update
        @product = find_product(params[:id])

        document_types = ['sds', 'pds', 'coa']

        document_types.each { |type|
            unless params[:product]["#{type}_file"].nil?
                uploaded_io = params[:product]["#{type}_file"]
                handle_upload(uploaded_io, type)
            end
        }
        
        unless params[:product][:sds_file].nil?
            uploaded_io = params[:product][:sds_file]
            handle_upload(uploaded_io, "sds")
        end

        unless params[:product][:pds_file].nil?
            uploaded_io = params[:product][:pds_file]
            handle_upload(uploaded_io, "pds")
        end

        render 'edit'
    end

    def download_document
        type = params[:document_type]
        prod = find_product(params[:id])
        info_path = 'alchemy-info-tables/res/Product_Information/' + prod.directory
        unless prod[type].nil?
            download_pdf(info_path, prod[type])
        end
    end

    private

    def download_pdf(directory, filename)
        send_file(Rails.root.join(directory, filename), filename: filename, type: "application/pdf")
    end

    def get_sds_expiry_date(product_id)
        sql = "SELECT \"SDS Expiry Date\"
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\"
        WHERE No_ = #{ActiveRecord::Base.connection.quote(product_id)}"
        records_array = Navision.connection.select_all(sql)
        return records_array.first["SDS Expiry Date"]
    end

    def new_product(csv_entry)
        prod = Product.new
        prod.product_id = csv_entry['ID']
        prod.directory = csv_entry['Directory']
        prod.sds = csv_entry['SDS']
        prod.pds = csv_entry['PDS']
        prod.coa = csv_entry['COA']
        prod.description = csv_entry['Description']
        prod.vendor_id = csv_entry['VENDOR']
        prod.vendor_name = csv_entry['Name']
        prod.sds_expiry = get_sds_expiry_date(prod.product_id)
        return prod
    end

    def get_product_csv
        products_csv_path = Rails.root.join('alchemy-info-tables', 'gen', 'NZ_ID_SDS_PDS_VENDOR_NAME.csv')
        products_csv = CSV.read(products_csv_path)
        titles = products_csv.shift
        return products_csv
    end

    def find_product(product_id)
        id = URI.unescape(params[:id])
        CSV.foreach(csv_path, :headers => true) do |csv_obj|
            if csv_obj['ID'] == id then
                return new_product(csv_obj)
            end
        end
        return nil
    end

    def write_uploaded_file(path, uploaded_io)
        filename = uploaded_io.original_filename
        File.open(Rails.root.join(path, filename), 'wb') do |file|
            file.write(uploaded_io.read)
        end
    end

    def regen_tables
        cmd = 'cd alchemy-info-tables; '
        cmd += 'make; '
        cmd += 'git add . 2>&1; '
        cmd += 'git commit -m "Data Sheet Update" 2>&1'
        `#{cmd}`
    end

    @@last_update = nil

    def get_products
        # update every hour
        if @@last_update.nil? || (Time.now - @@last_update) > 3600
            prods = Array.new
            CSV.foreach(csv_path, :headers => true) do |csv_obj|
                prods << new_product(csv_obj)
            end
            @@last_update = Time.now
            # save the products
            Product.delete_all
            prods.each(&:save)
            return prods
        end
        return Product.all
    end

    def csv_path
        return Rails.root.join('alchemy-info-tables', 'gen', 'NZ_ID_SDS_PDS_VENDOR_NAME.csv')
    end
 
end
