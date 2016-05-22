require 'rubygems'
require 'csv'
require 'uri'
require 'fileutils'
class ProductsController < ChartController

    @@document_types = ['sds', 'pds']
    @@info_path = Rails.root.join('alchemy-info-tables', 'res', 'Product_Information')
def index
        @products = Product.all.order :product_id
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

        begin
            @sales_html, @sales_js = get_charts
        rescue => ex
            puts 'Could not load charts, this should never appear in production logs'
            puts ex.message
        end
    end

    def where_clause
        return "t.\"Item No_\" = #{SqlUtils.escape(@product.product_id)}"
    end

    def edit
        @product = Product.find(params[:id])
        @misc_files = get_misc_files
    end

    def upload_file(uploaded_io)
        new_filename = uploaded_io.original_filename

        product_documents_path = @product.absolute_documents_path
        FileUtils.mkdir_p product_documents_path

        # Write new file
        write_uploaded_file(product_documents_path, uploaded_io)

        cmd = 'cd alchemy-info-tables; '
        cmd += 'git add . 2>&1; '
        cmd += 'git commit -m "Data Sheet Update" 2>&1'
        `#{cmd}`
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
            @product.errors.add("filename_error", "\"#{new_filename}\" does not begin with \"#{start}\"")
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

    def update_documents
        params[:product][:documents_attributes].each { |d|
            doc_data = d[1]

            # If there is an id, it already exists
            if doc_data.include? 'id'
                document = Document.find(doc_data[:id])
            else
                document = Document.new
            end
            
            # Update expiration, product and type
            unless doc_data[:expiration].blank?
                document.expiration = doc_data[:expiration]
            end
            document.product = @product
            document.document_type = DocumentType.find(doc_data[:document_type])

            # Now upload the file
            unless doc_data[:file].nil?
                uploaded_io = doc_data[:file]
                filename = uploaded_io.original_filename
                start = "#{document.document_type.type_code} - "
                unless filename.start_with?(start)
                    @product.errors.add("filename_error", "\"#{filename}\" does not begin with \"#{start}\"")
            return
                    next
                end
                upload_file(uploaded_io)
                path = @@info_path.join(@product.directory)
                document.filename = filename.to_s
                document.absolute_directory = path.to_s
            end

            if document.changed?
                document.save
            end
        }
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

        update_documents

        render 'show'
    end

    def download_file
        filename = params[:filename]
        path = Pathname.new(params[:path])
        send_file(path.join(filename), filename: filename, :disposition => 'inline')
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
        begin   
            doc = Document.find(params[:document_id])
        rescue
            render action: 'show'
            return
        end
        doc.delete_file
        doc.destroy
        @product.save
        render action: 'show'
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
