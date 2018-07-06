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

class Review < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewer
  belongs_to :pull
  has_many :review_comments

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # イベント
  #
  # - pending         : 保留中
  # - comment         : コメント
  # - request_changes : 修正を要求
  # - approve         : 承認
  #
  enum event: {
    pending:  1000,
    comment: 2000,
    request_changes: 3000,
    approve: 4000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :event, default: events[:pending]
  attribute :body, default: Settings.reviews.body

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :body, presence: true
  validates :working_hours, presence: true, on: %i(update)

  #
  # リモートに送るレビューデータの作成・レビューコメントの更新をする
  #
  def self.ready_to_review!(pull)
    review = new(
      pull: pull
    )
    review.save!
    review_comments = review.reviewer.review_comments.order(:created_at).where(changed_file: pull.changed_files)
    working_hours = review_comments.calc_working_hours
    review.update!(working_hours: working_hours)
    review_comments.each do |review_comment|
      review_comment.review = review
      review_comment.save!
    end
    review
  end

  #
  # リモートのPRにレビューする
  #
  def reflect!
    ActiveRecord::Base.transaction do
      request_body = { body: body, event: 'COMMENT', comments: [] }
      review_comments.each do |review_comment|
        comment = {
          path: review_comment.path,
          position: review_comment.position.to_i,
          body: review_comment.body
        }
        request_body[:comments] << comment
      end

      json_format_request_body = request_body.to_json
      response = Github::Request.receive_api_request_in_json_format_on "https://api.github.com/repos/#{pull.repo_full_name}/pulls/#{pull.number}/reviews", json_format_request_body, pull.repo.installation_id
      if response.code == '200'
        review_comments.each do |review_comment|
          review_comment.status = :commented
          review_comment.github_created_at = review_comment.updated_at
          review_comment.github_updated_at = review_comment.updated_at
          review_comment.save!
        end
        comment!
        pull.reviewed!
      else
        fail response.body
      end
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end
end
