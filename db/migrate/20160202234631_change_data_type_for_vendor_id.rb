class ChangeDataTypeForVendorId < ActiveRecord::Migration
  def change
      change_column :products, :vendor_id, :integer
  end
end
