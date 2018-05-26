class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.belongs_to :pull, foreign_key: true
      t.belongs_to :reviewer, foreign_key: true
      t.text :body
      t.string :state
      t.integer :event
      t.integer :working_hours
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
