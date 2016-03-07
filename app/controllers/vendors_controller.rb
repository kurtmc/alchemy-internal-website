class VendorsController < ChartController
    def index
        @vendors = Vendor.all.order :vendor_id
    end

    def set_fields
        @vendor = Vendor.find(params[:id])

        @sales_html, @sales_js = get_charts

        @image_filename = get_image_path
    end

    def show
        set_fields
    end

    def get_image_path
        images = Dir.glob(Rails.root.join('public', 'images', "#{@vendor.vendor_id}.*"))
        if images.length > 0
            return File.basename(images[0])
        end
        return nil
    end

    def where_clause
        return "t.\"Vendor No_\" = #{SqlUtils.escape(@vendor.vendor_id)}"
    end

    def colourize_data_sets!(data_sets)
        len = data_sets.length
        num = 0;
        
        for i in 0...len
            data_sets[i].colour.replace "hsla(#{num}, 100%, 50%, 0.8)"
            num += 255/len
        end
    end

    def handle_upload(uploaded_io)
        @vendor = Vendor.find(params[:id])
        original = uploaded_io.original_filename
        new_filename = "#{@vendor.vendor_id}#{File.extname(original)}"

        # Write new file
        path = Rails.root.join('public', 'images')

        File.open(path.join(new_filename), 'wb') do |file|
            file.write(uploaded_io.read)
        end
    end

    def update
        set_fields

        unless params[:vendor_logo]['logo_file'].nil?
            uploaded_io = params[:vendor_logo]['logo_file']
            handle_upload(uploaded_io)
        end

        render 'show'
    end
end
