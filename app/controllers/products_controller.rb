require 'rubygems'
require 'csv'
require 'uri'
require 'fileutils'
class ProductsController < ApplicationController
    before_filter :authenticate_user!

    @@document_types = ['sds', 'pds']

    def index
        # This is how to handle different request types
        @products = Product.all
        respond_to do |format|
            format.html # index.html.erb
            format.xml  { render xml: @products}
            format.json { render json: @products}
        end
    end

    def show
        @product = Product.find(params[:id])
    end

    def edit
        @product = Product.find(params[:id])
    end

    def handle_upload(uploaded_io, file_type)
        unless @@document_types.include? file_type.downcase
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

        product_documents_path = @product.absolute_documents_path
        FileUtils.mkdir_p product_documents_path

        # First delete old file
        unless old_filename.nil?
            FileUtils.rm_f(product_documents_path.join(old_filename))
        end

        # Write new file
        write_uploaded_file(product_documents_path, uploaded_io)

        regen_tables

        @product[field.downcase] = new_filename
        @product.save
    end

    def update
        @product = Product.find(params[:id])


        @@document_types.each { |type|
            unless params[:product]["#{type}_file"].nil?
                uploaded_io = params[:product]["#{type}_file"]
                handle_upload(uploaded_io, type)
            end
        }

        render 'show'
    end

    def download_document
        type = params[:document_type]
        prod = Product.find(params[:id])
        info_path = 'alchemy-info-tables/res/Product_Information/' + prod.directory
        unless prod[type].nil?
            download_pdf(info_path, prod[type])
        end
    end

    private
    def download_pdf(directory, filename)
        send_file(Rails.root.join(directory, filename), filename: filename, type: "application/pdf")
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
end
