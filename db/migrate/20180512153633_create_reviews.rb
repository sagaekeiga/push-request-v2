class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.belongs_to :pull, foreign_key: true
      t.belongs_to :reviewer, foreign_key: true
      t.integer :remote_id
      t.text :body
      t.string :commit_id
      t.string :state
      t.string :path
      t.integer :event
      t.integer :position
      t.time :working_hours
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
