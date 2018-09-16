class CreateWikis < ActiveRecord::Migration[5.1]
  def change
    create_table :wikis do |t|
      t.belongs_to :repo, foreign_key: true
      t.belongs_to :reviewee, foreign_key: true
      t.string :title
      t.text :body
      t.integer :status
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
