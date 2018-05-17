# == Schema Information
#
# Table name: reviews
#
#  id            :bigint(8)        not null, primary key
#  body          :text
#  deleted_at    :datetime
#  event         :integer
#  state         :string
#  working_hours :time
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

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :body, presence: true
  # @TODO 時間を計測 & 記録する処理
  # validates :working_hours, presence: true

  #
  # リモートのPRにレビューする
  #
  def reflect
    ActiveRecord::Base.transaction do
      request_body = { body: 'hoge', event: 'COMMENT', comments: [] }
      review_comments.each do |review_comment|
        comment = {
          path: review_comment.path,
          position: review_comment.position.to_i,
          body: review_comment.body
        }
        request_body[:comments] << comment
      end

      json_format_request_body = request_body.to_json
      response = GithubAPI.receive_api_request_in_json_format_on "https://api.github.com/repos/#{pull.repo_full_name}/pulls/#{pull.number}/reviews", json_format_request_body

      if response.code == '200'
        review.comment!
        review.pull.reviewed!
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
