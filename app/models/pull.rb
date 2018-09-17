# == Schema Information
#
# Table name: pulls
#
#  id          :bigint(8)        not null, primary key
#  base_label  :string
#  body        :string
#  deleted_at  :datetime
#  head_label  :string
#  number      :integer
#  status      :integer
#  title       :string
#  token       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  remote_id   :integer
#  repo_id     :bigint(8)
#  reviewee_id :bigint(8)
#  reviewer_id :bigint(8)
#
# Indexes
#
#  index_pulls_on_deleted_at   (deleted_at)
#  index_pulls_on_repo_id      (repo_id)
#  index_pulls_on_reviewee_id  (reviewee_id)
#  index_pulls_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#  fk_rails_...  (reviewee_id => reviewees.id)
#  fk_rails_...  (reviewer_id => reviewers.id)
#

class Pull < ApplicationRecord
  include GenToken, FriendlyId
  acts_as_paranoid
  paginates_per 20
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewee
  belongs_to :reviewer, optional: true
  belongs_to :repo
  has_many :changed_files, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :commits, dependent: :destroy

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :token, uniqueness: true
  validates :remote_id, presence: true, uniqueness: true, on: %i(create)
  validates :number, presence: true
  validates :title, presence: true
  validates :status, presence: true

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 性別
  #
  # - connected        : APIのレスポンスから作成された状態
  # - request_reviewed : レビューをリクエストした
  # - reviewed         : レビューを完了した
  # - completed        : リモートのPRをMerge/Closeした
  # - canceled         : キャンセルされた
  #
  enum status: {
    connected:  1000,
    request_reviewed: 2000,
    reviewed: 4000,
    completed: 5000,
    canceled: 6000
  }

  # -------------------------------------------------------------------------------
  # Delegations
  # -------------------------------------------------------------------------------
  delegate :full_name, to: :repo, prefix: true
  delegate :private, to: :repo, prefix: true

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:connected]

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  # deletedなpullを考慮しているかどうかがupdate_by_pull_request_event!との違い
  def self.fetch!(repo)
    ActiveRecord::Base.transaction do
      res_pulls = Github::Request.github_exec_fetch_pulls!(repo)
      res_pulls.each do |res_pull|
        pull = repo.pulls.with_deleted.find_or_initialize_by(
          remote_id: res_pull['id'],
          reviewee: repo.reviewee
        )
        pull.update_attributes!(
          remote_id:  res_pull['id'],
          number:     res_pull['number'],
          reviewee:   repo.reviewee,
          title:      res_pull['title'],
          body:       res_pull['body'],
          head_label: res_pull['head']['label'],
          base_label: res_pull['base']['label']
        )
        skill = Skill.fetch!(res_pull['head']['repo']['language'], repo)
        if pull&.deleted?
          pull.restore
          skillings = repo.skillings.with_deleted.where(resource_type: 'Repo')
          skillings.each(&:restore) if skillings.present?
        end
        Commit.fetch!(pull)
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_pull')
  end

  # pull_requestのeventで発火しリモートの変更を検知して更新する
  def self.update_by_pull_request_event!(params)
    ActiveRecord::Base.transaction do
      pull = find_by(remote_id: params[:id])
      if pull.present?
        pull.update!(
          title: params[:title],
          body:  params[:body]
        )
        pull.update_status_by!(params[:state])
      else
        repo = Repo.find_by(remote_id: params[:head][:repo][:id])
        pull = create!(
          remote_id: params['id'],
          number:    params[:number],
          title:     params[:title],
          body:      params[:body],
          repo:      repo
        )
        skill = Skill.fetch!(params[:head][:repo][:language], repo)
      end
      return if pull.nil?
      Commit.fetch!(pull)
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  def reviewer? current_reviewer
    reviewer == current_reviewer
  end

  # 最新のファイル差分を取得する
  def files_changed
    @changed_files = changed_files.where(commit: commits.last).compared.order(created_at: :asc)
  end

  # stateのパラメータに対応したstatusに更新する
  def update_status_by!(state_params)
    case state_params
    when 'closed', 'merged'
      completed!
    end
  end

  def can_update?
    present? && !changed_files&.review_commented? && changed_files.exists?
  end

  # レビューコメントを削除する
  def cancel_review_comments!
    changed_files.joins(:review_comments).each { |changed_file| changed_file.review_comments.delete_all }
  end
end
