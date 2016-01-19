require 'uri'

class Product < ActiveRecord::Base
    include SqlUtils
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
        self.sds_expiry = record["SDS Expiry Date"]
        self.description2 = record["Description 2"]
        self.unit_measure = record["Base Unit of Measure"]
        self.shelf_life = record["Shelf No_"]
        if self.shelf_life.blank?
            self.shelf_life = 'No information'
        end
        self.inventory = get_inventory(self.product_id)
        self.quantity_purchase_order = get_purchase_order(self.product_id)
        self.quantity_packing_slip = get_packing_slip(self.product_id)
    end

    def get_inventory(product_id)
        sql = "SELECT \"Item No_\", SUM(\"Quantity\") as \"Inventory\"
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item Ledger Entry\"
        WHERE \"Item No_\" = #{SqlUtils.escape(product_id)}
        GROUP BY \"Item No_\""
        records_array = SqlUtils.execute_sql(sql)
        return records_array.first["Inventory"]
    end

    def get_purchase_order(product_id)
        sql = "SELECT Quantity
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Purchase Line\" as a
        WHERE a.No_ = #{SqlUtils.escape(product_id)}"
        record = SqlUtils.execute_sql(sql).first
        if record.nil?
            return 0
        end
        return record["Quantity"]
    end

    def get_packing_slip(product_id)
        sql = "SELECT Quantity
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Sales Line\" as a
        WHERE a.No_ = #{SqlUtils.escape(product_id)}"
        record = SqlUtils.execute_sql(sql).first
        if record.nil?
            return 0
        end
        return record["Quantity"]
    end

    def get_nav_record_for_product(product_id)
        sql = "SELECT *
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\"
        WHERE No_ = #{SqlUtils.escape(product_id)}"
        records_array = SqlUtils.execute_sql(sql)
        return records_array.first
    end

    def self.get_sds_expiry_date(product_id)
        record = get_nav_record_for_product(product_id)
        return record["SDS Expiry Date"]
    end
    ## Initialistaion code
    def self.new_product(csv_entry)
        prod = Product.new
        prod.product_id = csv_entry['ID']
        prod.directory = csv_entry['Directory']
        prod.sds = csv_entry['SDS']
        prod.pds = csv_entry['PDS']
        prod.description = csv_entry['Description']
        prod.vendor_id = csv_entry['VENDOR']
        prod.vendor_name = csv_entry['Name']
        prod.update_fields
        return prod
    end

    def self.load_all
        csv_path = Rails.root.join('alchemy-info-tables', 'gen', 'NZ_ID_SDS_PDS_VENDOR_NAME.csv')
        prods = Array.new
        CSV.foreach(csv_path, :headers => true) do |csv_obj|
            prods << new_product(csv_obj)
        end
        # save the products
        Product.delete_all
        prods.each(&:save)
    end

end
