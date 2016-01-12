class AddCoaToProducts < ActiveRecord::Migration
  def change
    add_column :products, :coa, :string
  end
end
