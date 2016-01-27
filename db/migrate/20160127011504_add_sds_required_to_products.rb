class AddSdsRequiredToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sds_required, :boolean
  end
end
