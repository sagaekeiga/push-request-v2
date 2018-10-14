class CreateReviewersGithubAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :reviewers_github_accounts do |t|
      t.belongs_to :reviewer, foreign_key: true
      t.string :login
      t.bigint :owner_id
      t.string :avatar_url
      t.string :email
      t.string :user_type
      t.string :name
      t.string :nickname
      t.string :company
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
