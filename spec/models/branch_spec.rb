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

require 'rails_helper'

RSpec.describe Branch, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
