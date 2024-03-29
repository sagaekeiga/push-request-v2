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

class ContentTree < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :parent, foreign_key: 'parent_id', class_name: 'Content'
  belongs_to :child, foreign_key: 'child_id', class_name: 'Content'
end
