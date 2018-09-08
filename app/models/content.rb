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

  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :name, presence: true
  validates :path, presence: true
  validates :size, presence: true
  validates :file_type, presence: true
  validates :reviewee, uniqueness: { scope: %i(repo name path file_type) }

  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  # deletedなpullを考慮しているかどうかがupdate_by_pull_request_event!との違い
  def self.fetch!(repo)
    ActiveRecord::Base.transaction do
      res_contents = Github::Request.github_exec_fetch_repo_contents!(repo, '')
      res_contents.each do |res_content|
        content = repo.contents.with_deleted.find_or_initialize_by(path: res_content['path'], reviewee: repo.reviewee)
        content.set_file_type_by(res_content['type'])
        Rails.logger.info res_content
        Rails.logger.info res_content['content']
        content.update_attributes!(
          content:   res_content['content'],
          html_url:  res_content['html_url'],
          name:      res_content['name'],
          path:      res_content['path'],
          size:      res_content['size']
        )
        content.restore if content&.deleted?
      end
      return true unless repo.contents
      1.step do |index|
        parents =
          if index == 1
            repo.contents.dir
          else
            repo.contents.dir.select { |content| content.parent.present? && content.children.blank? }
          end
        break if parents.blank?
        parents.each do |parent|
          res_contents = Github::Request.github_exec_fetch_repo_contents!(repo, parent.path)
          next if res_contents.blank?
          res_contents.each do |res_content|
            res_content = Github::Request.github_exec_fetch_repo_contents!(repo, res_content['path']) if res_content['type'] == 'file'
            child = repo.contents.find_or_initialize_by(path: res_content['path'], reviewee: repo.reviewee)
            child.set_file_type_by(res_content['type'])
            Rails.logger.info res_content
            Rails.logger.info res_content['content']
            child.update_attributes!(
              content:   res_content['content'],
              html_url:  res_content['html_url'],
              name:      res_content['name'],
              path:      res_content['path'],
              size:      res_content['size']
            )
            content_tree = ContentTree.find_or_initialize_by(
              parent: parent,
              child:  child
            )
            content_tree.save!
          end
        end
      end
    end
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    fail I18n.t('views.error.failed_create_pull')
  end
  #
  # def self.reached_end_point?
  #   dir.pluck(:name).each do |file_name|
  #     next if dir.count > 0
  #     return false if dir.where(name: file_name).count > 0
  #   end
  #   true
  # end

  def set_file_type_by(file_type)
    case file_type
    when 'file'
      assign_attributes(file_type: :file)
    when 'dir'
      assign_attributes(file_type: :dir)
    end
  end
end
