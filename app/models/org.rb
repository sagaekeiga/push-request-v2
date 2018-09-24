# == Schema Information
#
# Table name: orgs
#
#  id          :bigint(8)        not null, primary key
#  avatar_url  :string
#  deleted_at  :datetime
#  description :string
#  login       :string
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  remote_id   :bigint(8)
#
# Indexes
#
#  index_orgs_on_deleted_at  (deleted_at)
#

class Org < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_many :reviewee_orgs, dependent: :destroy
  has_many :repos, as: :resource
  has_many :pulls, as: :resource
  has_many :issues, as: :resource
  has_many :wikis, as: :resource
  has_many :commits, as: :resource
  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 状態
  #
  # - is_invalid : 無効
  # - is_valid   : 有効
  #
  enum status: {
    is_invalid: 1000,
    is_valid:   2000
  }
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :remote_id, presence: true, uniqueness: true
  validates :login, presence: true
  validates :status, presence: true
  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:is_invalid]
end
