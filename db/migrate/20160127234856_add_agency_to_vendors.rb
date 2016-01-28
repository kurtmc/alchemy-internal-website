class AddAgencyToVendors < ActiveRecord::Migration
  def change
    add_reference :vendors, :agency, index: true
  end
end
