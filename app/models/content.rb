# == Schema Information
#
# Table name: contents
#
#  id            :bigint(8)        not null, primary key
#  content       :text
#  deleted_at    :datetime
#  file_type     :integer
#  html_url      :string
#  name          :string
#  path          :string
#  resource_type :string
#  size          :string
#  status        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repo_id       :bigint(8)
#  resource_id   :integer
#
# Indexes
#
#  index_contents_on_deleted_at  (deleted_at)
#  index_contents_on_repo_id     (repo_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

class Content < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :resource, polymorphic: true
  belongs_to :repo
  # ファイルツリー構造
  has_one :parent_tree, class_name: 'ContentTree', foreign_key: :child_id
  has_one :parent,      through: :parent_tree, source: :parent

  has_many :child_trees,  class_name: 'ContentTree', foreign_key: :parent_id, dependent: :destroy
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
  validates :file_type, presence: true
  validates :resource_type, uniqueness: { scope: %i(repo path file_type resource_id) }, on: %i(create)

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
  # InstanceMethods
  # -------------------------------------------------------------------------------
  # 選択したディレクトリ配下もそのディレクトリと同じ公開ステータスに
  def update_children_status
    return if children.includes(:children).blank?
    children.includes(:repo).each do |child|
      child.update(status: status)
    end
  end

  def is_sub_dir?
    parent.present? && children.blank?
  end
end
