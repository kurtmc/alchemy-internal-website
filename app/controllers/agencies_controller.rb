class AgenciesController < ChartController

    def index
        @agencies = Agency.all.order :agency_id
    end

    def show
        @agency = Agency.find(params[:id])
        vendors = @agency.vendors
        @products = Array.new
        vendors.each { |v|
            v.products.each { |p|
                @products << p
            }
        }
        @products = @products.sort_by {|p| p.product_id}

        
        unless Rails.env.test?
            set_fields
        end
    end

    def where_clause
        return "t.\"Global Dimension 1 Code\" = #{SqlUtils.escape(@agency.agency_id)}"
    end

    def set_fields
        unless Rails.env.development?
            @sales_html, @sales_js = get_charts
        end
        @image_filename = get_image_path
    end

    def get_image_path
        images = Dir.glob(Rails.root.join('public', 'images', "#{@agency.agency_id}.*"))
        if images.length > 0
            return File.basename(images[0])
        end
        return nil
    end

    def handle_upload(uploaded_io)
        original = uploaded_io.original_filename
        new_filename = "#{@agency.agency_id}#{File.extname(original)}"

        # Write new file
        path = Rails.root.join('public', 'images')

        File.open(path.join(new_filename), 'wb') do |file|
            file.write(uploaded_io.read)
        end
    end

    def update
        @agency = Agency.find(params[:id])
        set_fields

        unless params[:agency_logo]['logo_file'].nil?
            uploaded_io = params[:agency_logo]['logo_file']
            handle_upload(uploaded_io)
        end

        render 'show'
    end

end

