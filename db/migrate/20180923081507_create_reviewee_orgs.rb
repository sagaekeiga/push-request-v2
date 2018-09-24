class CreateRevieweeOrgs < ActiveRecord::Migration[5.1]
  def change
    create_table :reviewee_orgs do |t|
      t.belongs_to :reviewee
      t.belongs_to :org
      t.integer :role
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
