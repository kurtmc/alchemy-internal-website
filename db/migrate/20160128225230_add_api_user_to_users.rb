class AddApiUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_user, :boolean
  end
end
