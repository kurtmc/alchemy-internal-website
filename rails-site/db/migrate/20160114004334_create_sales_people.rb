class CreateSalesPeople < ActiveRecord::Migration
  def change
    create_table :sales_people do |t|
      t.string :salesperson_code
      t.string :name

      t.timestamps
    end
  end
end
