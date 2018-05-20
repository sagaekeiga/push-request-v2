# == Schema Information
#
# Table name: pulls
#
#  id          :bigint(8)        not null, primary key
#  body        :string
#  deleted_at  :datetime
#  number      :integer
#  state       :string
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
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewee
  belongs_to :reviewer, optional: true
  belongs_to :repo
  has_many :changed_files, dependent: :destroy

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :token, uniqueness: true
  validates :remote_id, presence: true, uniqueness: true, on: %i(create)
  # @TODO 重複されることが前提のカラムであるかどうかを確認
  validates :number, presence: true
  validates :state, presence: true
  validates :title, presence: true
  validates :status, presence: true

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 性別
  #
  # - connected        : APIのレスポンスから作成された状態
  # - request_reviewed : レビューをリクエストした
  # - agreed           : リクエストを承認した
  # - reviewed         : レビューを完了した
  # - completed        : リモートのPRをMerge/Closeした
  # - canceled         : キャンセルされた
  #
  enum status: {
    connected:  1000,
    request_reviewed: 2000,
    agreed: 3000,
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

  #
  # リモートのPRを保存 or リストアする
  #
  # @param [Repo] repo レポジトリ
  #
  def self.create_or_restore!(repo)
    ActiveRecord::Base.transaction do
      response_pulls_in_json_format = GithubAPI.receive_api_response_in_json_format_on "https://api.github.com/repos/#{repo.full_name}/pulls"
      response_pulls_in_json_format.each do |response_pull|
        pull = repo.pulls.with_deleted.find_by(remote_id: response_pull['id'], reviewee: repo.reviewee)
        if pull.nil?
          pull = repo.pulls.create!(
            remote_id: response_pull['id'],
            number: response_pull['number'],
            state: response_pull['state'],
            reviewee: repo.reviewee,
            title: response_pull['title'],
            body: response_pull['body']
          )

          skill = Skill.find_by(name: response_pull['head']['repo']['language'])
          skilling = skill.skillings.find_or_create_by!(
            resource_type: 'Repo',
            resource_id: repo.id
          )
        end
        if pull&.deleted?
          pull.restore
          skillings = repo.skillings.with_deleted.where(resource_type: 'Repo')
          skillings.each(&:restore) if skillings.present?
        end
        ChangedFile.create_or_restore!(pull)
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_pull')
  end

  def self.update_by_pull_request_event!(params)
    update_when_push!(params[:github_app][:check_suite]) if params[:github_app][:check_suite].present?
    update_by_oprating_on_gui!(params[:github_app][:pull_request]) if params[:github_app][:pull_request].present?
  end

  # PRの更新がhookされた時に、PRを更新する
  def self.update_when_push!(params)
    @pull = find_by(remote_id: params[:pull_requests][0]['id'])
    ActiveRecord::Base.transaction do
      response_pulls_in_json_format = GithubAPI.receive_api_response_in_json_format_on "https://api.github.com/repos/#{@pull.repo.full_name}/pulls/#{@pull.number}"
      @pull.update!(
        state: response_pulls_in_json_format['state'],
        title: response_pulls_in_json_format['title'],
        body: response_pulls_in_json_format['body']
      )
      ChangedFile.check_and_update!(@pull, params[:head_commit][:id])
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  # Close/Merge/titleやbodyの変更を検知して更新する
  def self.update_by_oprating_on_gui!(params)
    @pull = find_by(remote_id: params[:id])
    ActiveRecord::Base.transaction do
      @pull.update!(
        state: params[:state],
        title: params[:title],
        body: params[:body]
      )
      @pull.update_status_by!(params[:state])
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  def already_pairing?
    agreed? || reviewed? || completed?
  end

  def reviewer? current_reviewer
    reviewer == current_reviewer
  end

  def last_committed_changed_files
    changed_file = changed_files.order(:id).last
    changed_files.order(:id).where(head_commit_id: changed_file&.head_commit_id)
  end

  # stateのパラメータに対応したstatusに更新する
  def update_status_by!(state_params)
    case state_params
    when 'closed'
      completed!
    when 'merged'
      completed!
    when 'open'
      connected!
    end
  end
end
