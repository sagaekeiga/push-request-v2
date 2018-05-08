# == Schema Information
#
# Table name: repos
#
#  id         :bigint(8)        not null, primary key
#  full_name  :string
#  name       :string
#  private    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  remote_id  :integer
#  user_id    :bigint(8)
#
# Indexes
#
#  index_repos_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :repo do
    
  end
end
