class CreateReviewComments < ActiveRecord::Migration[5.1]
  def change
    create_table :review_comments do |t|
      t.belongs_to :reviewer, foreign_key: true
      t.belongs_to :review, foreign_key: true
      t.belongs_to :changed_file, foreign_key: true
      t.text :body
      t.string :path
      t.integer :position
      t.integer :github_id
      t.integer :status
      t.timestamp :github_created_at
      t.timestamp :github_updated_at
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
