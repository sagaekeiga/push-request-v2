# == Schema Information
#
# Table name: reviews
#
#  id            :bigint(8)        not null, primary key
#  body          :text
#  deleted_at    :datetime
#  event         :integer
#  path          :string
#  position      :integer
#  state         :string
#  working_hours :time
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  commit_id     :string
#  pull_id       :bigint(8)
#  remote_id     :integer
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
  has_one :changed_file

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
  # @TODO バリデーション書く
  # @TODO JSでViewにもバリデーション書く
  # @TODO AJAXで「Start Button」を実装する
  
  #
  # リモートのPRを保存 or リストアする
  #
  # @param [Repo] repo レポジトリ
  #
  def self.create_review!(review_params, target_pull, reviewer)
    paths = review_params[:path]
    positions = review_params[:position]
    bodies = review_params[:body]
    ActiveRecord::Base.transaction do
      paths.each.with_index do |path, i|
        review = reviewer.reviews.create!(
          pull: target_pull,
          position: positions[i].to_i,
          body: bodies[i],
          path: paths[i]
        )
      end
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  # @TODO stateはレスポンスで。commit_idも。
  def self.request_review!(target_pull)
    reviews = where(pull: target_pull)
    request_body = { 'body': 'hoge', 'event': 'COMMENT', 'comments': [] }
    ActiveRecord::Base.transaction do
      reviews.each do |review|
        comment = { 'path': review.path, 'position': review.position.to_i, 'body': review.body }
        request_body[:comments] << comment
        review.comment!
      end
      json_format_request_body = request_body.to_json
      response = GithubAPI.receive_api_request_in_json_format_on "https://api.github.com/repos/#{target_pull.repo_full_name}/pulls/#{target_pull.number}/reviews", json_format_request_body
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

end
