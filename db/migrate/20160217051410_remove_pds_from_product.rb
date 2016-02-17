class RemovePdsFromProduct < ActiveRecord::Migration
  def change
    remove_column :products, :pds, :string
  end
end
