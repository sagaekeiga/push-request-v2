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
  def self.create_or_restore!(installation_repositories_params)
    ActiveRecord::Base.transaction do
      installation_repositories_params[:repositories_added].each do |installation_repository_params|
        repo = with_deleted.find_or_create_by(remote_id: installation_repository_params[:id])
        repo.restore if repo&.deleted?
        repo.update_attributes!(
          remote_id: installation_repository_params[:id],
          name: installation_repository_params[:name],
          full_name: installation_repository_params[:full_name],
          private: installation_repository_params[:private],
          installation_id: installation_repositories_params[:installation][:id]
        )
        Pull.create_or_restore!(repo)
      end
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
end
