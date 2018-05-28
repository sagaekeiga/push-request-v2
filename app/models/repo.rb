# == Schema Information
#
# Table name: repos
#
#  id          :bigint(8)        not null, primary key
#  deleted_at  :datetime
#  full_name   :string
#  name        :string
#  private     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  remote_id   :integer
#  reviewee_id :bigint(8)
#
# Indexes
#
#  index_repos_on_deleted_at   (deleted_at)
#  index_repos_on_reviewee_id  (reviewee_id)
#
# Foreign Keys
#
#  fk_rails_...  (reviewee_id => reviewees.id)
#

class Repo < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewee
  has_many :pulls, dependent: :destroy
  has_many :skillings, dependent: :destroy, as: :resource
  has_many :skills, through: :skillings
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :full_name, presence: true, uniqueness: true
  validates :private, inclusion: { in: [true, false] }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :private, default: false

  # @TODO テストコードを書く
  #
  # リモートのレポジトリを保存する or リストアする
  #
  # @param [ActionController::Parameter] repositories_added_params addedなPOSTパラメータ
  #
  # @return [Boolean] 保存 or リストアに成功すればtrue、失敗すればfalseを返す
  #
  def self.create_or_restore!(repositories_added_params)
    ActiveRecord::Base.transaction do
      repo = with_deleted.find_by(remote_id: repositories_added_params[0][:id])
      if repo.nil?
        repo = create!(
          remote_id: repositories_added_params[0][:id],
          name: repositories_added_params[0][:name],
          full_name: repositories_added_params[0][:full_name],
          private: repositories_added_params[0][:private]
        )
      end
      repo.restore if repo&.deleted?
      Pull.create_or_restore!(repo)
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  # レビュワーのスキルに合致するPRを取得する
  def self.pulls_suitable_for reviewer
    repos = joins(:skillings).where(skillings: { skill_id: reviewer.skillings.pluck(:skill_id) })
    Pull.request_reviewed.where(repo_id: repos&.pluck(:id))
  end

  def self.check_installation_repositories(github_account)
    ActiveRecord::Base.transaction do
      reviewee = github_account.reviewee
      remote_ids = []
      response_repos_in_json_format = GithubAPI.receive_api_response_in_json_format_on "https://api.github.com/installation/repositories"
      response_repos_in_json_format['repositories'].each do |response_repo|
        repo = reviewee.repos.with_deleted.find_by(remote_id: response_repo['id'])
        attributes = {
          remote_id: response_repo['id'],
          name: response_repo['name'],
          full_name: response_repo['full_name'],
          private: response_repo['private']
        }
        if repo&.deleted?
          repo.restore
          skillings = repo.skillings.with_deleted.where(resource_type: 'Repo')
          skillings.each(&:restore) if skillings.present?
        end
        repo.update!(attributes) if repo
        repo = reviewee.repos.create!(attributes) if repo.nil?

        skill = Skill.find_by(name: response_repo['language'])
        skilling = skill.skillings.find_or_create_by!(
          resource_type: 'Repo',
          resource_id: repo.id
        )
        target_deleting_skilling = repo.skillings.where.not(skill: skilling.skill)
        target_deleting_skilling.delete_all if target_deleting_skilling

        repo.pulls.with_deleted.update_diff_or_create!(repo)
        remote_ids << response_repo['id']
      end
      reviewee.repos.where.not(remote_id: remote_ids)&.each(&:destroy)
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end
end
