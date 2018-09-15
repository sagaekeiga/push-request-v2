# == Schema Information
#
# Table name: changed_files
#
#  id           :bigint(8)        not null, primary key
#  additions    :integer
#  contents_url :string
#  deleted_at   :datetime
#  deletions    :integer
#  difference   :integer
#  filename     :string
#  patch        :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  commit_id    :bigint(8)
#  pull_id      :bigint(8)
#
# Indexes
#
#  index_changed_files_on_commit_id   (commit_id)
#  index_changed_files_on_deleted_at  (deleted_at)
#  index_changed_files_on_pull_id     (pull_id)
#
# Foreign Keys
#
#  fk_rails_...  (commit_id => commits.id)
#  fk_rails_...  (pull_id => pulls.id)
#

FactoryBot.define do
  factory :changed_file do
    
  end
end
