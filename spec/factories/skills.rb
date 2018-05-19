# == Schema Information
#
# Table name: skills
#
#  id         :bigint(8)        not null, primary key
#  deleted_at :datetime
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_skills_on_deleted_at  (deleted_at)
#

FactoryBot.define do
  factory :skill do
    
  end
end
