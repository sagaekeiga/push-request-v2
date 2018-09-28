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

class Membership < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :owner, foreign_key: 'owner_id', class_name: 'Reviewee'
  belongs_to :member, foreign_key: 'member_id', class_name: 'Reviewee'
  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 性別
  #
  # - invited : (OwnerがMemberを)招待した
  # - agreed  : (MemberがOwnerを)承認した
  #
  enum status: {
    invited: 1000,
    agreed:  2000
  }
  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:invited]
end
