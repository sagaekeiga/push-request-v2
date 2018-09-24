# == Schema Information
#
# Table name: repos
#
#  id              :bigint(8)        not null, primary key
#  deleted_at      :datetime
#  full_name       :string
#  name            :string
#  private         :boolean
#  resource_type   :string
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  installation_id :bigint(8)
#  remote_id       :integer
#  resource_id     :integer
#
# Indexes
#
#  index_repos_on_deleted_at  (deleted_at)
#

class Repo < ApplicationRecord
  acts_as_paranoid
  paginates_per 10
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :resource, polymorphic: true
  has_many :pulls, dependent: :destroy
  has_many :skillings, dependent: :destroy, as: :resource
  has_many :skills, through: :skillings
  has_many :contents, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :wikis, dependent: :destroy
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :full_name, presence: true, uniqueness: true
  validates :private, inclusion: { in: [true, false] }
  validates :installation_id, presence: true

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 性別
  #
  # - loding  : 取得中
  # - hidden  : 非公開
  # - showing : 公開
  #
  enum status: {
    loading: 1000,
    hidden:  2000,
    showing: 3000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:loading]
  attribute :private, default: false

  #
  # リモートのレポジトリを保存する or リストアする
  #
  # @param [ActionController::Parameter] repositories_added_params addedなPOSTパラメータ
  #
  # @return [Boolean] 保存 or リストアに成功すればtrue、失敗すればfalseを返す
  #
  def self.fetch!(params)
    resource_type = params['installation']['account']['type'].eql?('User') ? 'Reviewee' : 'Org'
    resource =
      if resource_type.eql?('Reviewee')
        Reviewees::GithubAccount.find_by(owner_id: params['installation']['account']['id']).reviewee
      else
        Org.find_by(remote_id: params['installation']['account']['id'])
      end
    return true if resource.nil?
    repos =
      if params['repositories_added'].present?
        params['repositories_added']
      else
        params['repositories']
      end
    repos.each do |repository|
      begin
        ActiveRecord::Base.transaction do
          repository = ActiveSupport::HashWithIndifferentAccess.new(repository)
          repo = with_deleted.find_or_create_by(remote_id: repository[:id])
          repo.restore if repo&.deleted?
          repo.update_attributes!(
            resource_type: resource_type,
            resource_id: resource.id,
            name: repository[:name],
            full_name: repository[:full_name],
            private: repository[:private],
            installation_id: params['installation']['id']
          )
          FetchContentJob.perform_later(repo)
          Pull.fetch!(repo)
          Issue.fetch!(repo)
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

  def import_wikis!(file_params, resource)
    ActiveRecord::Base.transaction do
      wikis.delete_all
      zipfile = file_params
      Zip::File.open(zipfile.path) do |zip|
        zip.each do |entry|
          next unless File.extname(entry.name).eql?('.md')
          @title = File.basename(entry.name).gsub('.md', '')
          ext = File.extname(entry.name)
          Tempfile.open([File.basename(entry.to_s), ext]) do |file|
            entry.extract(file.path) { true }
            body = file.read
            wiki = wikis.new(
              resource_type: resource.class.to_s,
              resource_id: resource.id,
              title: @title,
              body: body
            )
            wiki.save!
            file.close!
          end
        end
      end
    end
    true
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    false
  end
end
