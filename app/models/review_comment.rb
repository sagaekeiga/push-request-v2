# == Schema Information
#
# Table name: review_comments
#
#  id                :bigint(8)        not null, primary key
#  body              :text
#  deleted_at        :datetime
#  github_created_at :datetime
#  github_updated_at :datetime
#  path              :string
#  position          :integer
#  status            :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  changed_file_id   :bigint(8)
#  github_id         :bigint(8)
#  in_reply_to_id    :bigint(8)
#  review_id         :bigint(8)
#  reviewer_id       :bigint(8)
#
# Indexes
#
#  index_review_comments_on_changed_file_id  (changed_file_id)
#  index_review_comments_on_deleted_at       (deleted_at)
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
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :review, optional: true
  belongs_to :changed_file
  belongs_to :reviewer, optional: true

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 性別
  #
  # - pending   : コメントが作成された
  # - commented : レビューした
  #
  enum status: {
    pending:  1000,
    commented: 2000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:pending]

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :github_id, uniqueness: true, unless: -> { validation_context == :pending }
  validates :body, presence: true
  validates :path, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  def self.calc_working_hours
    start_time = self.first.created_at
    end_time = Time.zone.now
    working_hours = ((end_time - start_time).to_i / 60).floor
    working_hours > Settings.review_comments.max_working_hours ? Settings.review_comments.max_working_hours : working_hours
  end

  def self.create_or_restore!(pull)
    ActiveRecord::Base.transaction do
      response_review_comments_in_json_format = Github::Response.receive_api_response_in_json_format_on "#{Settings.github.api_domain}repos/#{pull.repo_full_name}/pulls/#{pull.number}/comments", pull.repo.installation_id
      response_review_comments_in_json_format.each do |response_review_comment|
        reviewer = Reviewers::GithubAccount.find_by(owner_id: response_review_comment['user']['id'])&.reviewer
        changed_file = pull.changed_files.find_by(
          commit_id: response_review_comment['commit_id'],
          filename: response_review_comment['path']
        )
        review_comment = changed_file&.review_comments&.with_deleted&.find_or_initialize_by(github_id: response_review_comment['id'], reviewer: reviewer)
        review_comment.restore if review_comment&.deleted?
        review_comment&.update_attributes!(
          github_id: response_review_comment['id'],
          body: response_review_comment['body'],
          path: response_review_comment['path'],
          position: response_review_comment['position'],
          reviewer: reviewer,
          status: :commented,
          in_reply_to_id: response_review_comment['in_reply_to_id'],
          github_created_at: response_review_comment['created_at'],
          github_updated_at: response_review_comment['updated_at']
        )
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_review_comment')
  end

  def self.recieve_immediate_review_comment!(params)
    ActiveRecord::Base.transaction do
      review_comment = ReviewComment.with_deleted.find_or_initialize_by(github_id: params[:comment][:id])
      pull = Pull.find_by(remote_id: params[:pull_request][:id])
      reviewer = Reviewers::GithubAccount.find_by(owner_id: params[:comment][:user][:id])&.reviewer
      sender = Reviewers::GithubAccount.find_by(owner_id: params[:sender][:id])&.reviewer
      changed_file = pull.changed_files.find_by(
        commit_id: params[:comment][:commit_id],
        filename: params[:comment][:path]
      )
      # github appからのコメントはsenderが一致しない
      if review_comment.persisted? && review_comment.body == params[:comment][:body] && sender.present?
        review_comment.destroy
      else
        review_comment.update_attributes!(
          github_id: params[:comment][:id],
          body: params[:comment][:body],
          path: params[:comment][:path],
          position: params[:comment][:position],
          changed_file: changed_file,
          status: :commented,
          in_reply_to_id: params[:comment][:in_reply_to_id],
          github_created_at: params[:comment][:created_at],
          github_updated_at: params[:comment][:updated_at]
        )
        review_comment.update_attributes!(reviewer: reviewer) if reviewer.present?
      end
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  def reviewer?(current_reviewer)
    reviewer == current_reviewer
  end

  def target_lines
    if position > 3
      changed_file.patch&.lines[(position - 3)..position]
    elsif position > 2
      changed_file.patch&.lines[(position - 2)..position]
    elsif position > 1
      changed_file.patch&.lines[(position - 1)..position]
    else
      [] << changed_file.patch&.lines[position]
    end
  end

  def send_github!(commit_id)
    comment = {
      body: body,
      in_reply_to: in_reply_to_id
    }
    response = Github.receive_api_request_in_json_format_on "#{Settings.github.api_domain}repos/#{changed_file.pull.repo_full_name}/pulls/#{changed_file.pull.number}/comments", comment.to_json, changed_file.pull.repo.installation_id
    if response.code == '201'
      response = JSON.load(response.body)
      update!(github_id: response['id'])
      p 'OK'
    else
      fail response.body
    end
  end

end
