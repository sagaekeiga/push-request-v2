# == Schema Information
#
# Table name: repos
#
#  id              :bigint(8)        not null, primary key
#  deleted_at      :datetime
#  full_name       :string
#  name            :string
#  private         :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  installation_id :bigint(8)
#  remote_id       :integer
#  reviewee_id     :bigint(8)
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
  paginates_per 10
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
  validates :installation_id, presence: true

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
  def self.fetch!(repositories_params)
    repos =
      if repositories_params['repositories_added'].present?
        repositories_params['repositories_added']
      else
        repositories_params['repositories']
      end
    repos.each do |repository|
      begin
        ActiveRecord::Base.transaction do
          repo = with_deleted.find_or_create_by(remote_id: repository['id'])
          repo.restore if repo&.deleted?
          repo.update_attributes!(
            remote_id: repository['id'],                               # レポジトリID
            name: repository['name'],                                  # レポジトリ名
            full_name: repository['full_name'],                        # ニックネーム + レポジトリ名
            private: repository['private'],                            # プライベート
            installation_id: repositories_params['installation']['id'] # GitHub AppのインストールID
          )
          Pull.create_or_restore!(repo)
        end
        true
      rescue => e
        Rails.logger.error e
        Rails.logger.error e.backtrace.join("\n")
        false
      end
    end
  end

  # レビュワーのスキルに合致するPRを取得する
  def self.pulls_suitable_for reviewer
    repos = joins(:skillings).where(skillings: { skill_id: reviewer.skillings.pluck(:skill_id) })
    Pull.includes(:repo).request_reviewed.where(repo_id: repos&.pluck(:id))
  end

  # publicなpullを返す
  def self.with_public_pulls
    repos = where(private: false)
    Pull.includes(:repo).where.not(status: :agreed).where(repo_id: repos&.pluck(:id))
  end
end
