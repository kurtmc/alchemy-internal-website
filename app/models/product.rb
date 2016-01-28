require 'uri'

class Product < ActiveRecord::Base
    include SqlUtils

    def self.documents_path
        return Rails.root.join('alchemy-info-tables', 'res', 'Product_Information')
    end

    def absolute_documents_path
        return Product.documents_path.join(self.directory)
    end

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
        record = records_array.first
        unless record.nil?
            return record["Inventory"]
        else
            return 0
        end
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

    def self.new_product_from_record(record)
        # Find old product or create new
        product = Product.find_by(product_id: record['No_'])
        if product.nil?
            product = Product.new
            product.product_id = record['No_']
        end

        # Hackery so that we can map product_id to direcories in the filesystem
        product.directory = record['No_'].gsub('/',"_") 

        docs = Dir.glob(self.documents_path.join(product.directory, '*'))
        docs = docs.map { |x| File.basename(x) }
        docs.each { |doc|
            if doc.start_with?('SDS - ')
                product.sds = doc
            elsif doc.start_with?('PDS - ')
                product.pds = doc
            end
        }

        product.vendor_id = record['Vendor No_']
        product.vendor_name = record['Vendor Name']
        product.description = record['Description']
        product.description2 = record['Description 2']
        product.new_description = record['New Description']
        product.sds_expiry = record['SDS Expiry Date']
        product.sds_required = record['SDS Required']
        product.unit_measure = record['Base Unit of Measure']
        product.shelf_life = record['Shelf No_']
        product.inventory = record['Inventory']
		product.quantity_purchase_order = record['Quantity Purchase Order']
		product.quantity_packing_slip = record['Quantity Packing Slip']
        
        if product.changed?
		    product.save
        end
    end

    def self.load_specific(product_id)
        csv_path = Rails.root.join('alchemy-info-tables', 'gen', 'NZ_ID_SDS_PDS_VENDOR_NAME.csv')
        prods = Array.new
        CSV.foreach(csv_path, :headers => true) do |csv_obj|
            if csv_obj['ID'] == product_id
                prod = new_product(csv_obj)
                prod.save
            end
        end
    end

    def self.load_all
        sql = "
			SELECT
				item.*,
				vendor.\"Name\" AS \"Vendor Name\",
				inventory.\"Inventory\",
				purchase.Quantity AS \"Quantity Purchase Order\",
				sales.Quantity AS \"Quantity Packing Slip\"
			FROM
				NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\" AS item
				LEFT JOIN NAVLIVE.dbo.\"Alchemy Agencies Pty Ltd$Vendor\" AS vendor
				ON item.\"Vendor No_\" = vendor.No_
				LEFT JOIN (
					SELECT
						\"Item No_\",
						SUM(\"Quantity\") AS \"Inventory\"
					FROM
						NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item Ledger Entry\"
					GROUP BY
						\"Item No_\"
				) inventory
				ON inventory.\"Item No_\" = item.No_
				LEFT JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Purchase Line\" as purchase
				ON item.No_ = purchase.No_
				LEFT JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Sales Line\" as sales
				ON item.No_ = sales.No_
                WHERE item.No_ NOT LIKE 'ZZ%'
        "
        records = SqlUtils.execute_sql(sql)
        records.each { |record|
            new_product_from_record(record)
        }
    end

    def get_vendor_id
        vendor = Vendor.find_by vendor_id: self.vendor_id
        return vendor.id
    end

end
