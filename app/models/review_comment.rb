# == Schema Information
#
# Table name: review_comments
#
#  id              :bigint(8)        not null, primary key
#  body            :text
#  path            :string
#  position        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  changed_file_id :bigint(8)
#  commit_id       :string
#  review_id       :bigint(8)
#  reviewer_id     :bigint(8)
#
# Indexes
#
#  index_review_comments_on_changed_file_id  (changed_file_id)
#  index_review_comments_on_review_id        (review_id)
#  index_review_comments_on_reviewer_id      (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (changed_file_id => changed_files.id)
#  fk_rails_...  (review_id => reviews.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

class ReviewComment < ApplicationRecord
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :review, optional: true
  belongs_to :changed_file
  belongs_to :reviewer

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :body, presence: true
  validates :path, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  # @TODO 時間を計測 & 記録する処理
  # validates :working_hours, presence: true
end
