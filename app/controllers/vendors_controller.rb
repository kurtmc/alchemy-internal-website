class VendorsController < ApplicationController
    before_filter :authenticate_user!
    def index
        @vendors = Vendor.all
    end

    def show
        @vendor = Vendor.find_by vendor_id: params[:id]
        @vendor.update_fields
    end
end
