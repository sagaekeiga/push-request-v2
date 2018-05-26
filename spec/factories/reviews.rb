# == Schema Information
#
# Table name: reviews
#
#  id            :bigint(8)        not null, primary key
#  body          :text
#  deleted_at    :datetime
#  event         :integer
#  state         :string
#  working_hours :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  pull_id       :bigint(8)
#  reviewer_id   :bigint(8)
#
# Indexes
#
#  index_reviews_on_deleted_at   (deleted_at)
#  index_reviews_on_pull_id      (pull_id)
#  index_reviews_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

FactoryBot.define do
  factory :review do
    
  end
end
