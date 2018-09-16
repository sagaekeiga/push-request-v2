# == Schema Information
#
# Table name: commits
#
#  id          :bigint(8)        not null, primary key
#  deleted_at  :datetime
#  message     :string
#  sha         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  pull_id     :bigint(8)
#  reviewee_id :bigint(8)
#
# Indexes
#
#  index_commits_on_deleted_at   (deleted_at)
#  index_commits_on_pull_id      (pull_id)
#  index_commits_on_reviewee_id  (reviewee_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#  fk_rails_...  (reviewee_id => reviewees.id)
#

require 'rails_helper'

RSpec.describe Commit, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
