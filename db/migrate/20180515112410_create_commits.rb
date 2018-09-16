class CreateCommits < ActiveRecord::Migration[5.1]
  def change
    create_table :commits do |t|
      t.belongs_to :reviewee, foreign_key: true
      t.belongs_to :pull, foreign_key: true
      t.string :sha
      t.string :message
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
