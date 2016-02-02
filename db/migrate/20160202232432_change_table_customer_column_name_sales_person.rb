class ChangeTableCustomerColumnNameSalesPerson < ActiveRecord::Migration
  def change
      rename_column :customers, :salesperson_id, :sales_person_id
  end
end
