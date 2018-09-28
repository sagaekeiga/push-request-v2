class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships do |t|
      t.belongs_to :owner, index: true
      t.belongs_to :member, index: true
      t.integer :status
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
