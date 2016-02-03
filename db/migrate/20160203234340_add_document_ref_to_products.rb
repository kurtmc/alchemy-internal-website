class AddDocumentRefToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :document, index: true
  end
end
