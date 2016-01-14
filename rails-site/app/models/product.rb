require 'uri'

class Product < ActiveRecord::Base
    def get_product_id
        return self.product_id.gsub('/',"%2F").gsub('%', "%25")
    end

    def get_sds_expiry_formatted
        if self.sds_expiry.nil?
            return 'EXPIRED!'
        end
        return self.sds_expiry.strftime("%Y-%m-%d")
    end

    def update_fields
        record = get_nav_record_for_product(self.product_id)
        puts record.inspect
        self.sds_expiry = record["SDS Expiry Date"]
        self.description2 = record["Description 2"]
        self.unit_measure = record["Base Unit of Measure"]
        self.shelf_life = record["Shelf No_"]
        if self.shelf_life.blank?
            self.shelf_life = 'No information'
        end
        self.inventory = get_inventory(self.product_id)
        # TODO figure out where these hide
        #self.quantity_purchase_order = record[]
        #self.quantity_packing_slip = record[]
    end

    def exec_sql(sql)
        return Navision.connection.select_all(sql)
    end

    def escape(value)
        return "#{ActiveRecord::Base.connection.quote(value)}"
    end

    def get_inventory(product_id)
        sql = "SELECT \"Item No_\", SUM(\"Quantity\") as \"Inventory\"
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item Ledger Entry\"
        WHERE \"Item No_\" = #{escape(product_id)}
        GROUP BY \"Item No_\""
        records_array = exec_sql(sql)
        puts records_array.inspect
        return records_array.first["Inventory"]
    end

    def get_nav_record_for_product(product_id)
        sql = "SELECT *
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\"
        WHERE No_ = #{escape(product_id)}"
        records_array = exec_sql(sql)
        return records_array.first
    end

    def self.get_sds_expiry_date(product_id)
        record = get_nav_record_for_product(product_id)
        return record["SDS Expiry Date"]
    end

end
