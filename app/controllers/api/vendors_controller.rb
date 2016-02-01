class Api::VendorsController < Api::ApiController

    def index
        @vendors = Vendor.all.order :vendor_id
        respond_to do |format|
            format.json {
                if params[:csv] == 'true'
                    render text: get_vendors_csv
                else
                    render json: @vendors
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
            return File.basename(images[0])
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
end
