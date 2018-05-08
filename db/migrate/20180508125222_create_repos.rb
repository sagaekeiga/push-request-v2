class CreateRepos < ActiveRecord::Migration[5.1]
  def change
    create_table :repos do |t|
      t.belongs_to :user, foreign_key: true
      t.integer :remote_id
      t.string :name
      t.string :full_name
      t.boolean :private
      t.timestamps
    end
  end
end
