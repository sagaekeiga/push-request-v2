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
  has_many :reviews, dependent: :destroy

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :token, uniqueness: true
  validates :remote_id, presence: true, uniqueness: true, on: %i(create)
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

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  # @TODO リファクタできる気がする
  # deletedなpullを考慮しているかどうかがupdate_by_pull_request_event!との違い
  def self.create_or_restore!(repo)
    ActiveRecord::Base.transaction do
      response_pulls_in_json_format = GithubAPI.receive_api_response_in_json_format_on "https://api.github.com/repos/#{repo.full_name}/pulls", repo.installation_id
      response_pulls_in_json_format.each do |response_pull|
        pull = repo.pulls.with_deleted.find_by(remote_id: response_pull['id'], reviewee: repo.reviewee)
        if pull.nil?
          pull = repo.pulls.create!(
            remote_id: response_pull['id'],
            number:    response_pull['number'],
            state:     response_pull['state'],
            reviewee:  repo.reviewee,
            title:     response_pull['title'],
            body:      response_pull['body']
          )
          skill = Skill.find_by(name: response_pull['head']['repo']['language'])
          skilling = skill.skillings.find_or_create_by!(
            resource_type: 'Repo',
            resource_id:   repo.id
          )
        end
        if pull&.deleted?
          pull.restore
          skillings = repo.skillings.with_deleted.where(resource_type: 'Repo')
          skillings.each(&:restore) if skillings.present?
        end
        ChangedFile.fetch!(pull)
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
          state: params[:state],
          title: params[:title],
          body:  params[:body]
        )
        pull.update_status_by!(params[:state])
      else
        repo = Repo.find_by(remote_id: params[:head][:repo][:id])
        pull = create!(
          remote_id: params['id'],
          number:    params[:number],
          state:     params[:state],
          title:     params[:title],
          body:      params[:body],
          repo:      repo
        )
        skill = Skill.find_by(name: params[:head][:repo][:language])
        skilling = skill.skillings.find_or_create_by!(
          resource_type: 'Repo',
          resource_id:   repo.id
        )
      end
      ChangedFile.check_and_update!(pull, params[:head][:sha])
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  def self.update_diff_or_create!(repo)
    ActiveRecord::Base.transaction do
      response_pulls_in_json_format = GithubAPI.receive_api_response_in_json_format_on "https://api.github.com/repos/#{repo.full_name}/pulls", repo.installation_id
      response_pulls_in_json_format.each do |response_pull|
        attributes = {
          remote_id: response_pull['id'],
          number:    response_pull['number'],
          state:     response_pull['state'],
          reviewee:  repo.reviewee,
          title:     response_pull['title'],
          body:      response_pull['body']
        }
        pull = with_deleted.find_by(remote_id: response_pull['id'])
        pull = create!(attributes) if pull.nil?
        if pull.can_update?
          pull.update!(attributes)
          pull.restore if pull&.deleted?
          # request_reviewed/agreed/reviewed の場合にconnectedにならぬように。
          pull.connected! if completed?
        end
        ChangedFile.fetch!(pull)
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_pull')
  end

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  def already_pairing?
    agreed? || reviewed? || completed?
  end

  def reviewer? current_reviewer
    reviewer == current_reviewer
  end

  def last_committed_changed_files
    changed_file = changed_files.order(:id).last
    changed_files.order(:id).where(commit_id: changed_file&.commit_id)
  end

  # stateのパラメータに対応したstatusに更新する
  def update_status_by!(state_params)
    case state_params
    when 'closed', 'merged'
      completed!
    when 'open'
      connected!
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
