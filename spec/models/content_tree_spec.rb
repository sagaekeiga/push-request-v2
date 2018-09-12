# == Schema Information
#
# Table name: content_trees
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  child_id   :bigint(8)
#  parent_id  :bigint(8)
#
# Indexes
#
#  index_content_trees_on_child_id   (child_id)
#  index_content_trees_on_parent_id  (parent_id)
#

require 'rails_helper'

RSpec.describe ContentTree, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
