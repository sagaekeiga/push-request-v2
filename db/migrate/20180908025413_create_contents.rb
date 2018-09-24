class CreateContents < ActiveRecord::Migration[5.1]
  def change
    create_table :contents do |t|
      t.integer :resource_id
      t.string  :resource_type
      t.belongs_to :repo, foreign_key: true
      t.integer :file_type
      t.integer :status
      t.string :size
      t.string :name
      t.string :path
      t.text :content
      t.string :html_url
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
