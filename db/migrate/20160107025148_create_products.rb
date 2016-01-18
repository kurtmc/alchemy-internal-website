class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :product_id
      t.string :directory
      t.string :sds
      t.string :pds
      t.string :vendor_id
      t.string :vendor_name
      t.string :description
      t.string :description2
      t.datetime :sds_expiry
      t.string :unit_measure
      t.string :shelf_life
      t.decimal :inventory
      t.decimal :quantity_purchase_order
      t.decimal :quantity_packing_slip


      t.timestamps
    end

    Product.load_all

  end
end
