class CreateConfigTables < ActiveRecord::Migration
  def change
    create_table :config_tables do |t|
      t.string :key :index
      t.text :value

      t.timestamps
    end
  end
end
