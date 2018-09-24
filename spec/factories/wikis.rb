# == Schema Information
#
# Table name: wikis
#
#  id            :bigint(8)        not null, primary key
#  body          :text
#  deleted_at    :datetime
#  resource_type :string
#  status        :integer
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repo_id       :bigint(8)
#  resource_id   :integer
#
# Indexes
#
#  index_wikis_on_deleted_at  (deleted_at)
#  index_wikis_on_repo_id     (repo_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

FactoryBot.define do
  factory :wiki do
    
  end
end
