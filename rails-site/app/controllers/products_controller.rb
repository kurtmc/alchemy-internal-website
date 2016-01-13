require 'rubygems'
require 'csv'
require 'uri'

class ProductsController < ApplicationController
    def index
        @products = Product.all
    end

    def show
        @product = find_product(params[:id])
    end

    def edit
        @product = find_product(params[:id])
    end

    def handle_upload(uploaded_io, file_type)
        unless ['sds', 'pds'].include? file_type.downcase
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
            @product.save
    end

    def update
        @product = find_product(params[:id])

        document_types = ['sds', 'pds']

        document_types.each { |type|
            unless params[:product]["#{type}_file"].nil?
                uploaded_io = params[:product]["#{type}_file"]
                handle_upload(uploaded_io, type)
            end
        }
        
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

    def find_product(product_id)
        id = URI.unescape(params[:id])
        product = Product.find_by product_id: id
        product.update_fields
        return product
    end

    def write_uploaded_file(path, uploaded_io)
        filename = uploaded_io.original_filename
        File.open(Rails.root.join(path, filename), 'wb') do |file|
            file.write(uploaded_io.read)
        end
    end

    def regen_tables
        cmd = 'cd alchemy-info-tables; '
        cmd += 'git add . 2>&1; '
        cmd += 'git commit -m "Data Sheet Update" 2>&1'
        `#{cmd}`
    end

    def get_products
        return Product.all
    end

end
