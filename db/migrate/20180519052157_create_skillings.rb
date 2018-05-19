class CreateSkillings < ActiveRecord::Migration[5.1]
  def change
    create_table :skillings do |t|
      t.belongs_to :skill, foreign_key: true
      t.integer :resource_id
      t.string  :resource_type
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
