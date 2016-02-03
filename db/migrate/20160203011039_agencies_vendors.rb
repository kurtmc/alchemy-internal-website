class AgenciesVendors < ActiveRecord::Migration
    def change
        create_table :agencies_vendors, :id => false do |t|
            t.integer :agency_id
            t.integer :vendor_id
        end
    end
end
