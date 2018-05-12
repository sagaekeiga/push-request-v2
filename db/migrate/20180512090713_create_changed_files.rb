class CreateChangedFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :changed_files do |t|
      t.belongs_to :pull, foreign_key: true
      t.string :sha
      t.string :filename
      t.integer :status
      t.integer :additions
      t.integer :deletions
      t.integer :changes
      t.string :blob_url
      t.string :raw_url
      t.string :contents_url
      t.text :patch
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
