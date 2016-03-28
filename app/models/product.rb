require 'uri'

class Product < ActiveRecord::Base
    has_and_belongs_to_many :customer_users
    belongs_to :vendor
    has_many :documents
    accepts_nested_attributes_for :documents, :allow_destroy => true

    extend NavisionRecord

    include SqlUtils

    def vendor_image
        images = Dir.glob(Rails.root.join('public', 'images', "#{self.vendor.vendor_id}.*"))
        if images.length > 0
            return File.basename(images[0])
        end
        return nil
    end

    def attributes
        super.merge({'vendor_image' => vendor_image})
    end

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

    def self.new_active_record(record, code)
        # Find old product or create new
        product = Product.find_by(product_id: record['No_'])
        if product.nil?
            product = Product.new
            product.product_id = record['No_']
        end

        # Hackery so that we can map product_id to direcories in the filesystem
        product.directory = record['No_'].gsub('/',"_") 

        absolute_path = self.documents_path.join(product.directory)

        docs = Dir.glob(absolute_path.join('*'))
        docs = docs.map { |x| File.basename(x) }
        docs.each { |doc|
            if doc.start_with?('SDS - ')
                type = DocumentType.find_by type_code: 'SDS'
                if type.nil?
                    type = DocumentType.new
                    type.type_code = 'SDS'
                    type.type_description = 'Safety Data Sheet'
                    type.save
                end
            elsif doc.start_with?('PDS - ')
                type = DocumentType.find_by type_code: 'PDS'
                if type.nil?
                    type = DocumentType.new
                    type.type_code = 'PDS'
                    type.type_description = 'Product Data Sheet'
                    type.save
                end
            end

            document = Document.find_by(absolute_directory: absolute_path.to_s, filename: doc.to_s)
            if document.nil?
                document = Document.new
            end

            document.document_type = type

            # Hackery to get SDS expiry dates from Navision
            if document.document_type.type_code == 'SDS'
                unless record['SDS Expiry Date'].nil?
                    if document.expiration.nil? || document.expiration < record['SDS Expiry Date']
                        document.expiration = record['SDS Expiry Date']
                    end
                end
            end

            document.absolute_directory = absolute_path.to_s
            document.filename = doc.to_s
            document.save

            unless product.documents.include?(document)
                product.documents << document
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

    def self.get_sql(code)
        return "
			SELECT
				item.*,
				vendor.\"Name\" AS \"Vendor Name\",
				inventory.\"Inventory\",
				purchase.Quantity AS \"Quantity Purchase Order\",
				sales.Quantity AS \"Quantity Packing Slip\"
			FROM
				#{self.table('Item', code)} AS item
				LEFT JOIN #{self.table('Vendor', code)} AS vendor
				ON item.\"Vendor No_\" = vendor.No_
				LEFT JOIN (
					SELECT
						\"Item No_\",
						SUM(\"Quantity\") AS \"Inventory\"
					FROM
						#{self.table('Item Ledger Entry', code)}
					GROUP BY
						\"Item No_\"
				) inventory
				ON inventory.\"Item No_\" = item.No_
				LEFT JOIN #{self.table('Purchase Line', code)} as purchase
				ON item.No_ = purchase.No_
				LEFT JOIN #{self.table('Sales Line', code)} as sales
				ON item.No_ = sales.No_
                WHERE item.No_ NOT LIKE 'ZZ%'
        "
    end

end
