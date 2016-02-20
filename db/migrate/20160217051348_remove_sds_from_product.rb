class RemoveSdsFromProduct < ActiveRecord::Migration
  def change
    remove_column :products, :sds, :string
  end
end
