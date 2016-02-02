class Api::VendorsController < Api::ApiController

    def index
        @vendors = Vendor.all.order :vendor_id
        respond_to do |format|
            format.json {
                if params[:csv] == 'true'
                    render text: get_vendors_csv
                else
                    render json: get_vendors_json
                end
            }
        end
    end

    def show
        respond_to do |format|
            format.json { render json: Vendor.find(params[:id])}
        end
    end

    def get_image_path(vendor_id)
        images = Dir.glob(Rails.root.join('public', 'images', "#{vendor_id}.*"))
        if images.length > 0
            name = File.basename(images[0])
            unless name == '.'
                return name
            end
        end
        return nil
    end

    def get_vendors_csv
        mapping = Hash.new
        mapping['id'] = 'id'
        mapping['vendor_id'] = 'vendor_id'
        
        csv_string = CSV.generate do |csv|
            header = mapping.values
            header << 'image_filename'
            csv << header
            all_vendors = Vendor.select(mapping.keys)
            all_vendors.each do |vendor|
                row = vendor.attributes.values
                row << get_image_path(vendor.vendor_id)
                csv << row
            end
        end
    end

    def get_vendors_json
        vendors = Vendor.all.as_json
        vendors.each do |v|
            v[:image_filename] = get_image_path(v[:vendor_id])
        end
        return vendors
    end
end
