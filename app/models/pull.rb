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
  validates :remote_id, presence: true, uniqueness: true
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

  def already_pairing?
    agreed? || reviewed? || completed?
  end

  def reviewer? current_reviewer
    reviewer == current_reviewer
  end
end
