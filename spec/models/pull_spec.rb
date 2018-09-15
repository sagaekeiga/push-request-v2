# == Schema Information
#
# Table name: pulls
#
#  id          :bigint(8)        not null, primary key
#  base_label  :string
#  body        :string
#  deleted_at  :datetime
#  head_label  :string
#  number      :integer
#  status      :integer
#  title       :string
#  token       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  remote_id   :integer
#  repo_id     :bigint(8)
#  reviewee_id :bigint(8)
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_pulls_on_deleted_at   (deleted_at)
#  index_pulls_on_repo_id      (repo_id)
#  index_pulls_on_reviewee_id  (reviewee_id)
#  index_pulls_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#  fk_rails_...  (reviewee_id => reviewees.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

require 'rails_helper'

RSpec.describe Pull, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
