class CreatePulls < ActiveRecord::Migration[5.1]
  def change
    create_table :pulls do |t|
      t.belongs_to :repo, foreign_key: true
      t.integer :resource_id
      t.string  :resource_type
      t.integer :remote_id
      t.integer :number
      t.string :title
      t.string :body
      t.integer :status
      t.string :token
      t.string :base_label
      t.string :head_label
      t.datetime :deleted_at, index: true
      t.timestamps
    end
    add_index :pulls, :remote_id, unique: true
  end
end
