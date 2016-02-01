class AddCustomerUserToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :customer_user, index: true
  end
end
