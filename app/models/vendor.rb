class Vendor < ActiveRecord::Base
    def self.load_all
        Vendor.delete_all
        sql = "SELECT *
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Vendor\""
        records = SqlUtils.execute_sql(sql)
        records.each { |record|
            vendor = new_vendor(record)
            vendor.save
        }
    end

    def self.new_vendor(record)
        vendor = Vendor.find_by vendor_id: record["No_"]
        if vendor.nil?
            vendor = Vendor.new
            vendor.vendor_id = record["No_"]
        end
        vendor.vendor_name = record["Name"]
        return vendor
    end

    def update_fields
    end
end
