class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :document_type, index: true
      t.string :absolute_directory
      t.string :filename
      t.date :expiration
      t.references :product, index: true

      t.timestamps
    end
  end
end
