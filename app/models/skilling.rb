# == Schema Information
#
# Table name: skillings
#
#  id            :bigint(8)        not null, primary key
#  deleted_at    :datetime
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :integer
#  skill_id      :bigint(8)
#
# Indexes
#
#  index_skillings_on_deleted_at  (deleted_at)
#  index_skillings_on_skill_id    (skill_id)
#
# Foreign Keys
#
#  fk_rails_...  (skill_id => skills.id)
#

class Skilling < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :skill
  belongs_to :resource, polymorphic: true
  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :name, to: :skill, prefix: true
end
