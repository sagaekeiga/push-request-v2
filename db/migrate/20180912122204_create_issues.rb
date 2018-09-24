class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :issues do |t|
      t.integer :resource_id
      t.string  :resource_type
      t.belongs_to :repo, foreign_key: true
      t.bigint :remote_id
      t.integer :number
      t.integer :status
      t.integer :publish
      t.string :title
      t.text :body
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
