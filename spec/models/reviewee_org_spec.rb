# == Schema Information
#
# Table name: reviewee_orgs
#
#  id          :bigint(8)        not null, primary key
#  deleted_at  :datetime
#  role        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  org_id      :bigint(8)
#  reviewee_id :bigint(8)
#
# Indexes
#
#  index_reviewee_orgs_on_deleted_at   (deleted_at)
#  index_reviewee_orgs_on_org_id       (org_id)
#  index_reviewee_orgs_on_reviewee_id  (reviewee_id)
#

require 'rails_helper'

RSpec.describe RevieweeOrg, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
