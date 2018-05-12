class CreatePulls < ActiveRecord::Migration[5.1]
  def change
    create_table :pulls do |t|
      t.belongs_to :reviewee, foreign_key: true
      t.belongs_to :repo, foreign_key: true
      t.integer :remote_id
      t.integer :number
      t.string :state
      t.string :title
      t.string :body
      t.integer :status
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
