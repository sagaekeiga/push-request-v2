class CreateChangedFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :changed_files do |t|
      t.belongs_to :pull, foreign_key: true
      t.belongs_to :commit, foreign_key: true
      t.string :filename
      t.integer :additions
      t.integer :deletions
      t.integer :difference
      t.string :contents_url
      t.text :patch
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
