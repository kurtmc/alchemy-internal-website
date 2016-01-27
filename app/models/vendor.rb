class Vendor < ActiveRecord::Base

    extend NavisionRecord

    def self.get_sql
        return "
            SELECT
            DISTINCT item.\"Global Dimension 1 Code\" as \"Dimension\"
            FROM
            NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\" AS item
            WHERE
            item.\"Global Dimension 1 Code\" <> ''
            AND NOT item.\"Global Dimension 1 Code\" LIKE 'ZZ%'
        "
    end

    def self.new_active_record(record)
        vendor = Vendor.find_by vendor_id: record['Dimension']
        if vendor.nil?
            vendor = Vendor.new
            vendor.vendor_id = record['Dimension']
        end
        vendor.vendor_name = record["No_"]
        return vendor
    end
end
