class CreateReviewComments < ActiveRecord::Migration[5.1]
  def change
    create_table :review_comments do |t|
      t.belongs_to :reviewer, foreign_key: true
      t.belongs_to :review, foreign_key: true
      t.belongs_to :changed_file, foreign_key: true
      t.text :body
      t.string :commit_id
      t.string :path
      t.integer :position
      t.timestamps
    end
  end
end
