class CreateNoticeBoards < ActiveRecord::Migration
  def change
    create_table :notice_boards do |t|
      t.string :content

      t.timestamps
    end
  end
end
