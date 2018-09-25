# == Schema Information
#
# Table name: content_trees
#
#  id         :bigint(8)        not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  child_id   :bigint(8)
#  parent_id  :bigint(8)
#
# Indexes
#
#  index_content_trees_on_child_id    (child_id)
#  index_content_trees_on_deleted_at  (deleted_at)
#  index_content_trees_on_parent_id   (parent_id)
#

FactoryBot.define do
  factory :content_tree do
    
  end
end
