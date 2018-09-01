# == Schema Information
#
# Table name: review_comments
#
#  id              :bigint(8)        not null, primary key
#  body            :text
#  deleted_at      :datetime
#  path            :string
#  position        :integer
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  changed_file_id :bigint(8)
#  in_reply_to_id  :bigint(8)
#  remote_id       :bigint(8)
#  review_id       :bigint(8)
#  reviewer_id     :bigint(8)
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
  validates :remote_id, uniqueness: true, allow_nil: true
  validates :body,      presence: true
  validates :path,      presence: true

  def self.calc_working_hours
    return 0 if self.first.nil?
    start_time = self.first.created_at
    end_time = Time.zone.now
    working_hours = ((end_time - start_time).to_i / 60).floor
    working_hours > Settings.review_comments.max_working_hours ? Settings.review_comments.max_working_hours : working_hours
  end

  # リモート上での削除・返信を取得・保存
  def self.fetch_by_delete_and_reply!(params)
    ActiveRecord::Base.transaction do
      review_comment = ReviewComment.with_deleted.find_or_initialize_by(remote_id: params[:comment][:id])
      pull = Pull.find_by(remote_id: params[:pull_request][:id])
      reviewer = Reviewers::GithubAccount.find_by(owner_id: params[:comment][:user][:id])&.reviewer
      sender = Reviewers::GithubAccount.find_by(owner_id: params[:sender][:id])&.reviewer
      changed_file = pull.changed_files.find_by(
        commit_id: params[:comment][:commit_id],
        filename:  params[:comment][:path]
      )
      return review_comment.destroy if review_comment.can_destroy?(sender, params) # Destroy
      if params[:changes]                         # Edit
        review_comment.update_attributes!(
          remote_id:    params[:comment][:id],
          body:         params[:comment][:body],
          path:         params[:comment][:path],
          position:     params[:comment][:position],
          changed_file: changed_file,
          status:       :commented
        )
        return
      end
      Rails.application.config.another_logger.info 'params[:comment][:in_reply_to_id]'
      Rails.application.config.another_logger.info params[:comment][:in_reply_to_id]
      if params[:comment][:in_reply_to_id]        # Reply
        review_comment.update_attributes!(
          remote_id:      params[:comment][:id],
          body:           params[:comment][:body],
          path:           params[:comment][:path],
          position:       params[:comment][:position],
          status:         :commented,
          changed_file:   changed_file,
          in_reply_to_id: params[:comment][:in_reply_to_id]
        )
        return
      end
      # unless params[:sender][:type] == 'Bot'
      # Create
      review_comment = changed_file.review_comments.find_or_initialize_by(
        body:     params[:comment][:body],
        path:     params[:comment][:path],
        position: params[:comment][:position],
      )
      # end
      review_comment.update_attributes!(
        remote_id:      params[:comment][:id],
        status:         :commented,
        in_reply_to_id: params[:comment][:in_reply_to_id]
      )
      ReviewerMailer.comment(review_comment).deliver_later if review_comment.reviewer
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
    response = Github::Request.github_exec_review_comment!(comment.to_json, changed_file.pull)
    if response.code == '201'
      response = JSON.load(response.body)
      update!(remote_id: response['id'])
      Rails.logger.info 'OK'
    else
      fail response.body
    end
  end

  # 対象のレビューコメントを取得する
  def target_comments
    ReviewComment.where(review: review, path: path, position: position)
  end

  # 返信コメントを返す
  def replies
    ReviewComment.where(
      changed_file: changed_file,
      review:       nil,
      path:         path,
      position:     position
    ).order(:created_at)
  end

  # deleteなwebhook
  def can_destroy?(sender, params)
    # 1. 保存されているかどうか
    # 2. 削除対象であればbodyは同じ
    # 3. 送信者とレビュワーは一致しない
    persisted? && body == params[:comment][:body] && sender.present?
  end
end
