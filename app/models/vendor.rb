class Vendor < ActiveRecord::Base
    belongs_to :agency

    extend NavisionRecord

    def self.get_sql
        return "
        SELECT *
        FROM
        NAVLIVE.dbo.\"Alchemy Agencies Ltd$Vendor\" AS vendor JOIN(
        SELECT
        DISTINCT item.\"Vendor No_\",
        item.\"Global Dimension 1 Code\"
        FROM
        NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\" AS item
        ) GLOBAL
        ON vendor.\"No_\" = global.\"Vendor No_\"
        "
    end

    def self.new_active_record(record)
        vendor = Vendor.find_by vendor_id: record['No_']
        if vendor.nil?
            vendor = Vendor.new
            vendor.vendor_id = record['No_']
        end
        vendor.vendor_name = record["Name"]

        # Add self to agency
        agency = Agency.find_by agency_id: record["Global Dimension 1 Code"]
        unless agency.nil?
            agency.vendors << vendor
            agency.save
        end

        return vendor
    end
end
