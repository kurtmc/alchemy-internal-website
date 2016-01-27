class Vendor < ActiveRecord::Base

    extend NavisionRecord

    def self.get_sql
        return "SELECT * FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Vendor\""
    end

    def self.new_active_record(record)
        vendor = Vendor.find_by vendor_id: record["No_"]
        if vendor.nil?
            vendor = Vendor.new
            vendor.vendor_id = record["No_"]
        end
        vendor.vendor_name = record["Name"]
        return vendor
    end
end
