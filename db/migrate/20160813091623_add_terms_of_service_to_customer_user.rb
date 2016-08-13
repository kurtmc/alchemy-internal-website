class AddTermsOfServiceToCustomerUser < ActiveRecord::Migration
  def change
  	add_column :customer_users, :terms_of_use, :boolean, default: false 
  end
end
