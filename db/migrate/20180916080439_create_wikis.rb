class CreateWikis < ActiveRecord::Migration[5.1]
  def change
    create_table :wikis do |t|
      t.belongs_to :repo, foreign_key: true
      t.integer :resource_id
      t.string  :resource_type
      t.string :title
      t.text :body
      t.integer :status
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
