class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.string :item_id
      t.string :unit_measure
      t.decimal :min_quantity
      t.decimal :published_price
      t.decimal :cost
      t.decimal :price
      t.datetime :start_date
      t.datetime :end_date
      t.references :customer, index: true

      t.timestamps
    end
  end
end
