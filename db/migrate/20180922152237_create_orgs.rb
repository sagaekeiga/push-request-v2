class CreateOrgs < ActiveRecord::Migration[5.1]
  def change
    create_table :orgs do |t|
      t.bigint :remote_id
      t.string :login
      t.string :avatar_url
      t.string :description
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
