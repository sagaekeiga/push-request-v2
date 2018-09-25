# == Schema Information
#
# Table name: memberships
#
#  id         :bigint(8)        not null, primary key
#  deleted_at :datetime
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :bigint(8)
#  owner_id   :bigint(8)
#
# Indexes
#
#  index_memberships_on_deleted_at  (deleted_at)
#  index_memberships_on_member_id   (member_id)
#  index_memberships_on_owner_id    (owner_id)
#

FactoryBot.define do
  factory :membership do
    
  end
end
