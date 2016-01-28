class AgenciesController < ApplicationController

    def index
        @agencies = Agency.all.order :agency_id
    end

    def show
        @agency = Agency.find(params[:id])
        vendors = @agency.vendors
        vendor_ids = Array.new
        unless vendors.nil?
            vendors.each { |v|
                vendor_ids << v.vendor_id
            }
        end
        @products = Product.where(vendor_id: vendor_ids).order :product_id
    end

end

