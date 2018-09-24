# == Schema Information
#
# Table name: branches
#
#  id         :bigint(8)        not null, primary key
#  deleted_at :datetime
#  event      :string
#  message    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_branches_on_deleted_at  (deleted_at)
#

FactoryBot.define do
  factory :branch do
    
  end
end
