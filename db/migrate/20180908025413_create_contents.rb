class CreateContents < ActiveRecord::Migration[5.1]
  def change
    create_table :contents do |t|
      t.belongs_to :reviewee, foreign_key: true
      t.belongs_to :repo, foreign_key: true
      t.integer :file_type
      t.integer :status
      t.string :size
      t.string :name
      t.string :path
      t.string :html_url
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
