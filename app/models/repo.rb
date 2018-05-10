# == Schema Information
#
# Table name: repos
#
#  id         :bigint(8)        not null, primary key
#  deleted_at :datetime
#  full_name  :string
#  name       :string
#  private    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  remote_id  :integer
#  user_id    :bigint(8)
#
# Indexes
#
#  index_repos_on_deleted_at  (deleted_at)
#  index_repos_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Repo < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :user
  has_many :pulls
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
  # @TODO languageを登録する
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
end
