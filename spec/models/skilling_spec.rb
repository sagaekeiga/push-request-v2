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
#  index_skillings_on_deleted_at                     (deleted_at)
#  index_skillings_on_resource_id_and_resource_type  (resource_id,resource_type)
#  index_skillings_on_skill_id                       (skill_id)
#
# Foreign Keys
#
#  fk_rails_...  (skill_id => skills.id)
#

require 'rails_helper'

RSpec.describe Skilling, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
