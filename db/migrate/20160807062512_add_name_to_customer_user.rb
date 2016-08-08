class AddNameToCustomerUser < ActiveRecord::Migration
  def change
  	add_column :customer_users, :name, :string
  	add_column :customer_users, :company_name, :string 
  end
end
