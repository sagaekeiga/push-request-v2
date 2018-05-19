class CreateSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :skills do |t|
      t.string :name
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
