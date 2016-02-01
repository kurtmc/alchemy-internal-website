class CreateJoinTableProductCustomerUser < ActiveRecord::Migration
  def change
    create_join_table :products, :customer_users do |t|
      # t.index [:product_id, :customer_user_id]
      # t.index [:customer_user_id, :product_id]
    end
  end
end
