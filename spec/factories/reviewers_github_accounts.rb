# == Schema Information
#
# Table name: reviewers_github_accounts
#
#  id          :bigint(8)        not null, primary key
#  avatar_url  :string
#  company     :string
#  deleted_at  :datetime
#  email       :string
#  login       :string
#  name        :string
#  nickname    :string
#  user_type   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :bigint(8)
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_reviewers_github_accounts_on_deleted_at   (deleted_at)
#  index_reviewers_github_accounts_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (reviewer_id => reviewers.id)
#

FactoryBot.define do
  factory :reviewers_github_account, class: 'Reviewers::GithubAccount' do
    
  end
end
