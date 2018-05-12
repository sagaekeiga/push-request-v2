# == Schema Information
#
# Table name: pulls
#
#  id         :bigint(8)        not null, primary key
#  body       :string
#  deleted_at :datetime
#  number     :integer
#  state      :string
#  status     :integer
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  remote_id  :integer
#  repo_id    :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_pulls_on_deleted_at  (deleted_at)
#  index_pulls_on_repo_id     (repo_id)
#  index_pulls_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :pull do
    
  end
end
