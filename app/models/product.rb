require 'uri'

class Product < ActiveRecord::Base
    has_and_belongs_to_many :customer_users
    belongs_to :vendor

    extend NavisionRecord

    include SqlUtils

    def self.documents_path
        return Rails.root.join('alchemy-info-tables', 'res', 'Product_Information')
    end

    def absolute_documents_path
        return Product.documents_path.join(self.directory)
    end

    def get_sds_expiry_formatted
        if self.sds_expiry.nil?
            return 'EXPIRED!'
        end
        return self.sds_expiry.strftime("%Y-%m-%d")
    end

    def self.new_active_record(record)
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

        product.vendor = Vendor.find_by vendor_id: record['Vendor No_']
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
        
        return product
    end

    def self.get_sql
        return "
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
    end

    # TODO actually link the product and vendor models
    # Also remove the useage of this in view/products/show.html.erb
    def get_vendor_id
        vendor = Vendor.find_by vendor_id: self.vendor_id
        return vendor.id
    end

end
