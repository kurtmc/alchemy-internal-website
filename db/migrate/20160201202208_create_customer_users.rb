class CreateCustomerUsers < ActiveRecord::Migration
  def change
    create_table :customer_users do |t|
      t.string :email
      t.string :password

      t.timestamps
    end
  end
end
