# == Schema Information
#
# Table name: users_github_accounts
#
#  id              :bigint(8)        not null, primary key
#  avatar_url      :string
#  company         :string
#  deleted_at      :datetime
#  email           :string
#  html_url        :string
#  location        :string
#  login           :string
#  name            :string
#  nickname        :string
#  public_gists    :integer
#  public_repos    :integer
#  url             :string
#  user_created_at :datetime
#  user_type       :string
#  user_updated_at :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  gravatar_id     :string
#  owner_id        :integer
#  user_id         :bigint(8)
#
# Indexes
#
#  index_users_github_accounts_on_deleted_at  (deleted_at)
#  index_users_github_accounts_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Users::GithubAccount < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user
end
