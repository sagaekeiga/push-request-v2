# == Schema Information
#
# Table name: contents
#
#  id            :bigint(8)        not null, primary key
#  content       :text
#  deleted_at    :datetime
#  file_type     :integer
#  html_url      :string
#  name          :string
#  path          :string
#  resource_type :string
#  size          :string
#  status        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repo_id       :bigint(8)
#  resource_id   :integer
#
# Indexes
#
#  index_contents_on_deleted_at  (deleted_at)
#  index_contents_on_repo_id     (repo_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

FactoryBot.define do
  factory :content do
    
  end
end
