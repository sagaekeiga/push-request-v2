# == Schema Information
#
# Table name: issues
#
#  id            :bigint(8)        not null, primary key
#  body          :text
#  deleted_at    :datetime
#  number        :integer
#  publish       :integer
#  resource_type :string
#  status        :integer
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  remote_id     :bigint(8)
#  repo_id       :bigint(8)
#  resource_id   :integer
#
# Indexes
#
#  index_issues_on_deleted_at  (deleted_at)
#  index_issues_on_repo_id     (repo_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

FactoryBot.define do
  factory :issue do
    
  end
end
