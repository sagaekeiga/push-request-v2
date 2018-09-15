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

class Commit < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewee
  belongs_to :pull
  has_many :changed_files, dependent: :destroy
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  def self.fetch!(pull)
    ActiveRecord::Base.transaction do
      res_commits = Github::Request.github_exec_fetch_commits!(pull)
      res_commits.each do |res_commit|
        commit = pull.commits.with_deleted.find_or_initialize_by(sha: res_commit['sha'], reviewee: pull.repo.reviewee)
        commit.restore if commit.deleted?
        commit.update_attributes!(message: res_commit['commit']['message'])
        ChangedFile.fetch!(commit)
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_commit')
  end
end
