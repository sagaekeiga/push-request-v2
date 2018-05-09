class CreateUsersGithubAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :users_github_accounts do |t|
      t.belongs_to :user, foreign_key: true
      t.string :login
      t.integer :owner_id
      t.string :avatar_url
      t.string :gravatar_id
      t.string :email
      t.string :url
      t.string :html_url
      t.string :url
      t.string :user_type
      t.string :name
      t.string :nickname
      t.string :company
      t.string :location
      t.integer :public_repos
      t.integer :public_gists
      t.datetime :user_created_at
      t.datetime :user_updated_at
      t.datetime :deleted_at, index: true
      t.timestamps
    end
  end
end
