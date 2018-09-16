# == Schema Information
#
# Table name: issues
#
#  id          :bigint(8)        not null, primary key
#  body        :text
#  deleted_at  :datetime
#  number      :integer
#  publish     :integer
#  status      :integer
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  remote_id   :bigint(8)
#  repo_id     :bigint(8)
#  reviewee_id :bigint(8)
#
# Indexes
#
#  index_issues_on_deleted_at   (deleted_at)
#  index_issues_on_repo_id      (repo_id)
#  index_issues_on_reviewee_id  (reviewee_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#  fk_rails_...  (reviewee_id => reviewees.id)
#

class Issue < ApplicationRecord
  acts_as_paranoid
  paginates_per 20
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewee
  belongs_to :repo
  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # ステータス
  #
  # - opened : 作業中
  # - closed : 完了
  #
  enum status: {
    opened: 1000,
    closed: 2000
  }
  # 公開状況
  #
  # - hidden  : 非公開
  # - showing : 公開中
  #
  enum publish: {
    hidden:  1000,
    showing: 2000
  }
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, presence: true, uniqueness: true
  validates :number, presence: true
  validates :title, presence: true
  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :publish, default: publishes[:hidden]
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  def self.fetch!(repo)
    ActiveRecord::Base.transaction do
      # JSON
      res_issues = Github::Request.github_exec_fetch_issues!(repo)
      res_issues.each do |res_issue|
        next if res_issue.has_key?('pull_request')
        issue = repo.issues.find_or_initialize_by(
          reviewee: repo.reviewee,
          remote_id: res_issue['id'],
          number: res_issue['number']
        )
        issue.update_attributes!(
          title: res_issue['title'],
          body: res_issue['body']
        )
        issue.update_status_by!(res_issue['state'])
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_issue')
  end

  def self.update_by_issue_event!(params)
    ActiveRecord::Base.transaction do
      issue = find_or_initialize_by(
        remote_id: params[:issue][:id],
        number: params[:issue][:number]
      )
      repo_id = Repo.find_by(remote_id: params[:repository][:id]).id
      issue.update_attributes!(
        repo_id: repo_id,
        remote_id: params[:issue][:id],
        title: params[:issue][:title],
        body: params[:issue][:body]
      )
      issue.update_status_by!(params[:issue][:state])
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
  # stateのパラメータに対応したstatusに更新する
  def update_status_by!(state_params)
    case state_params
    when 'open'
      opened!
    when 'closed'
      closed!
    end
  end
end
