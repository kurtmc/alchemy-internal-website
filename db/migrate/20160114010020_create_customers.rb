class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :customer_id
      t.string :name
      t.decimal :balance
      t.decimal :credit_limit
      t.decimal :current
      t.decimal :last_1_to_30
      t.decimal :last_31_to_60
      t.decimal :last_31_90
      t.decimal :last_90_plus
      t.references :salesperson, index: true

      t.timestamps
    end
  end
end
