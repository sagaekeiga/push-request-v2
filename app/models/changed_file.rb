# == Schema Information
#
# Table name: changed_files
#
#  id             :bigint(8)        not null, primary key
#  additions      :integer
#  blob_url       :string
#  contents_url   :string
#  deleted_at     :datetime
#  deletions      :integer
#  difference     :integer
#  filename       :string
#  patch          :text
#  raw_url        :string
#  sha            :string
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  head_commit_id :string
#  pull_id        :bigint(8)
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
  has_many :review_comments

  def self.create_or_restore!(pull)
    ActiveRecord::Base.transaction do
      response_changed_files_in_json_format = GithubAPI.receive_api_response_in_json_format_on "https://api.github.com/repos/#{pull.repo_full_name}/pulls/#{pull.number}/files"
      response_changed_files_in_json_format.each do |response_changed_file|
        changed_file = pull.changed_files.with_deleted.find_by(sha: response_changed_file['sha'])
        if changed_file.nil?
          changed_file = pull.changed_files.create!(
            sha: response_changed_file['sha'],
            additions: response_changed_file['additions'],
            blob_url: response_changed_file['blob_url'],
            difference: response_changed_file['changes'],
            contents_url: response_changed_file['contents_url'],
            deletions: response_changed_file['deletions'],
            filename: response_changed_file['filename'],
            patch: response_changed_file['patch'],
            raw_url: response_changed_file['raw_url'],
            status: response_changed_file['status']
          )
        end
        changed_file.restore if changed_file&.deleted?
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_changed_file')
  end

  def self.check_and_update!(pull, sha)
    ActiveRecord::Base.transaction do
      response_changed_files_in_json_format = GithubAPI.receive_api_response_in_json_format_on "https://api.github.com/repos/#{pull.repo_full_name}/pulls/#{pull.number}/files"
      response_changed_files_in_json_format.each do |response_changed_file|
        changed_file = pull.changed_files.find_or_create_by!(
          sha: sha,
          additions: response_changed_file['additions'],
          blob_url: response_changed_file['blob_url'],
          difference: response_changed_file['changes'],
          contents_url: response_changed_file['contents_url'],
          deletions: response_changed_file['deletions'],
          filename: response_changed_file['filename'],
          patch: response_changed_file['patch'],
          raw_url: response_changed_file['raw_url'],
          status: response_changed_file['status']
        )
      end
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_changed_file')
  end
end
