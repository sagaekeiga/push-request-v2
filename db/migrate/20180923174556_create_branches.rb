class CreateBranches < ActiveRecord::Migration[5.1]
  def change
    create_table :branches do |t|
      t.string :event
      t.string :message
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
