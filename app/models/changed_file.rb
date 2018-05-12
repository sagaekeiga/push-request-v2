# == Schema Information
#
# Table name: changed_files
#
#  id           :bigint(8)        not null, primary key
#  additions    :integer
#  blob_url     :string
#  changes      :integer
#  contents_url :string
#  deleted_at   :datetime
#  deletions    :integer
#  filename     :string
#  patch        :text
#  raw_url      :string
#  sha          :string
#  status       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  pull_id      :bigint(8)
#
# Indexes
#
#  index_changed_files_on_deleted_at  (deleted_at)
#  index_changed_files_on_pull_id     (pull_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_id => pulls.id)
#

class ChangedFile < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :pull

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # ステータス
  #
  # - added : git add
  #
  enum status: {
    added:  1000
  }
end
