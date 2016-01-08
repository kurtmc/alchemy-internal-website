class CreateNavisions < ActiveRecord::Migration
  def change
    create_table :navisions do |t|

      t.timestamps
    end
  end
end
