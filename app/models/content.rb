# == Schema Information
#
# Table name: contents
#
#  id          :bigint(8)        not null, primary key
#  content     :text
#  deleted_at  :datetime
#  file_type   :integer
#  html_url    :string
#  name        :string
#  path        :string
#  size        :string
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  repo_id     :bigint(8)
#  reviewee_id :bigint(8)
#
# Indexes
#
#  index_contents_on_deleted_at   (deleted_at)
#  index_contents_on_repo_id      (repo_id)
#  index_contents_on_reviewee_id  (reviewee_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#  fk_rails_...  (reviewee_id => reviewees.id)
#

class Content < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewee
  belongs_to :repo
  # 自己結合
  has_one :parent_tree, class_name: 'ContentTree', foreign_key: :child_id
  has_one :parent,      through: :parent_tree, source: :parent

  has_many :child_trees,  class_name: 'ContentTree', foreign_key: :parent_id
  has_many :children,     through: :child_trees,  source: :child
  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # ファイルタイプ
  #
  # - file : ファイル
  # - dir  : ディレクトリ
  #
  enum file_type: {
    file: 1000,
    dir:  2000
  }
  # 公開状況
  #
  # - hidden  : 非公開
  # - showing : 公開
  #
  enum status: {
    hidden:   1000,
    showing:  2000
  }
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :name, presence: true
  validates :path, presence: true
  validates :size, presence: true
  validates :file_type, presence: true
  validates :reviewee, uniqueness: { scope: %i(repo path file_type) }, on: %i(create)

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:hidden]

  # -------------------------------------------------------------------------------
  # Scope
  # -------------------------------------------------------------------------------
  # 最上層のディレクトリ・ファイルを取得
  scope :top, lambda {
    order(file_type: :desc, name: :asc).
      includes(:parent).select { |content| content.parent.nil? }
  }

  # 配下のディレクトリ・ファイルを取得
  scope :sub, lambda { |content|
    if content.dir?
      order(file_type: :desc, name: :asc).includes(:repo)
    end
  }
  # -------------------------------------------------------------------------------
  # Callbacks
  # -------------------------------------------------------------------------------
  after_update *%i(update_children_status)

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  # deletedなpullを考慮しているかどうかがupdate_by_pull_request_event!との違い
  def self.fetch!(repo)
    ActiveRecord::Base.transaction do
      # apiから引数repoに合致した情報取得
      res_contents = Github::Request.github_exec_fetch_repo_contents!(repo)

      res_repo_branchs = Github::Request.github_exec_fetch_repo_branches!(repo)
      tree_sha = res_repo_branchs['commit']['commit']['tree']['sha']
      res_trees = Github::Request.github_exec_fetch_trees!(repo, tree_sha)
      res_trees.each do |trees|
        trees.each do |tree|
          content = repo.contents.new(
            name: res_content['path'],
            reviewee: repo.reviewee,
            content:   tree['content'],
            html_url:  tree['url'],
            size:      tree['size']
          )
          content.set_file_type_by(res_content['mode'])

      # 一番上の階層のfileを取得
      Content.save_top_dirs_and_files(repo, res_contents)
      top_dirs_and_files = repo.contents
      return true unless top_dirs_and_files
      # 無限ループで階層ごとにデータを取得
      1.step do |index|
        # 一番上の階層のdir取得
        parents =
          if index == 1
            top_dirs_and_files.dir
          else
            top_dirs_and_files.dir.select { |content| content.is_sub_or_dir? }
          end
          # 空なら無限ループ解除
        break if parents.blank?
        # サブディレクトリ・ファイルの取得
        parents.each(&:fetch_sub_dirs_and_files!)
      end
      repo.hidden!
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_contents')
  end

  def self.save_top_dirs_and_files(repo, res_contents)
    res_content_arr = []

    res_contents.each do |res_content|
      # 画像やvendor配下はレビュワーが見る必要がなくデータ量が多いため除外
      next if Settings.contents.prohibited_files.include?(res_content['name'])
      content = Content.fetch_single_content!(repo, res_content)
      res_content_arr << content
      # content.restore if content&.deleted?
    end
    # 一番上の階層のdirとfileを保存
    Content.import res_content_arr
  end

  def fetch_sub_dirs_and_files!
    count = 0
    begin
      ActiveRecord::Base.transaction do

        res_contents = Github::Request.github_exec_fetch_repo_contents!(repo, path)

        next if res_contents.blank?

        children = []
        content_trees = []
        res_contents.each do |res_content|

          next if Settings.contents.prohibited_files.include?(res_content['name'])
          child = Content.fetch_single_content!(repo, res_content)
          children << child

        end
        Content.import(children, validate: false)

        children.pluck(:id).each do |child_id|
          content_tree = ContentTree.new(
            parent: self,
            child_id: child_id
          )
          content_trees << content_tree
        end
        ContentTree.import(content_trees, validate: false)
      end
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      fail I18n.t('views.error.failed_create_contents')
      count += 1
      retry if count < 3
    end
  end

  def self.fetch_single_content!(repo, res_content)
    res_content = Github::Request.github_exec_fetch_repo_contents!(repo, res_content['path']) if res_content['type'] == 'file'

    content = repo.contents.new(
      path: res_content['path'],
      name:     res_content['name'],
      reviewee: repo.reviewee,
      content:   res_content['content'],
      html_url:  res_content['html_url'],
      size:      res_content['size']
    )
    content.set_file_type_by(res_content['type'])
    content
  end

  # レスポンスはString型であり、Enumに対応できるよう変換する
  def set_file_type_by(file_type)
    case file_type
    when 'file'
      assign_attributes(file_type: :file)
    when 'dir'
      assign_attributes(file_type: :dir)
    end
  end

  # 選択したディレクトリ配下もそのディレクトリと同じ公開ステータスに
  def update_children_status
    return if children.includes(:children).blank?
    children.includes(:repo, :reviewee).each do |child|
      child.update(status: status)
    end
  end

  def is_sub_or_dir?
    parent.present? && children.blank?
  end
end
