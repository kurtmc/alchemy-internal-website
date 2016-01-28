class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :agency_id
      t.string :name

      t.timestamps
    end
  end
end
