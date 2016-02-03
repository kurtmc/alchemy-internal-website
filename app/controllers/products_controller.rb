require 'rubygems'
require 'csv'
require 'uri'
require 'fileutils'
class ProductsController < ApplicationController
    before_filter :authenticate_user!

    @@document_types = ['sds', 'pds']
    @@info_path = Rails.root.join('alchemy-info-tables', 'res', 'Product_Information')

    def index
        # This is how to handle different request types
        @products = Product.all.order :product_id
        respond_to do |format|
            format.html # index.html.erb
            format.xml  { render xml: @products}
            format.json { render json: @products}
        end
    end

    def get_misc_files
        product_info_path = @@info_path.join(@product.directory)
        all_files = Dir.glob(product_info_path.join('*'))
        all_files.map!{ |x| File.basename(x) }
        misc_files = Array.new
        all_files.each { |file|
            add_to_misc = true
            @@document_types.each { |doc_type|
                start = "#{doc_type.upcase} - "
                if file.start_with?(start)
                    add_to_misc = false
                end
            }
            if add_to_misc
                misc_files << file
            end
        }
        return misc_files
    end

    def show
        @product = Product.find(params[:id])
        @misc_files = get_misc_files
        unless @product.sds.nil?
            @sds_filename = @product.sds
            @sds_path = @product.absolute_documents_path.join(@product.sds)
        end
    end

    def edit
        @product = Product.find(params[:id])
        @misc_files = get_misc_files
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
        unless params[:product]['misc_file'].nil?
            uploaded_io = params[:product]['misc_file']
            filename = uploaded_io.original_filename
            path = @@info_path.join(@product.directory)

            # First delete old file
            FileUtils.rm_f(path.join(filename))

            # Write new file
            File.open(path.join(filename), 'wb') do |file|
                file.write(uploaded_io.read)
            end
        end

        @misc_files = get_misc_files

        render 'show'
    end

    def download_document
        prod = Product.find(params[:id])
        type = params[:document_type]
        product_path = @@info_path.join(prod.directory)

        if type == 'misc'
            name = params[:document_name]
            send_file(product_path.join(name), filename: name, :disposition => 'inline')
            return
        end


        unless prod[type].nil?
            download_pdf(product_path, prod[type])
        end
    end

    def remove_document
        @product = Product.find(params[:id])
        name = params[:document_name]
        FileUtils.rm_f(@@info_path.join(@product.directory, name))
        @misc_files = get_misc_files
        render 'show'
    end

    private
    def download_pdf(directory, filename)
        send_file(Rails.root.join(directory, filename), filename: filename, type: "application/pdf", :disposition => 'inline')
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
