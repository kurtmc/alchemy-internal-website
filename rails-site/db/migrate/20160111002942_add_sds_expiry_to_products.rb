class AddSdsExpiryToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sds_expiry, :datetime
  end
end
