class RemoveVendorNameFromProducts < ActiveRecord::Migration
  def change
      remove_column :products, :vendor_name
  end
end
