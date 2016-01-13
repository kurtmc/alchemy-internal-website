class CreateProducts < ActiveRecord::Migration
  def change
    drop_table :products
    create_table :products do |t|
      t.string :product_id
      t.string :directory
      t.string :sds
      t.string :pds
      t.string :vendor_id
      t.string :vendor_name
      t.string :description
      t.datetime :sds_expiry

      t.timestamps
    end
  end
end
