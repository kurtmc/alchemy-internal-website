class AddNewDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :new_description, :string
  end
end
