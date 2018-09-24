# == Schema Information
#
# Table name: wikis
#
#  id            :bigint(8)        not null, primary key
#  body          :text
#  deleted_at    :datetime
#  resource_type :string
#  status        :integer
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repo_id       :bigint(8)
#  resource_id   :integer
#
# Indexes
#
#  index_wikis_on_deleted_at  (deleted_at)
#  index_wikis_on_repo_id     (repo_id)
#
# Foreign Keys
#
#  fk_rails_...  (repo_id => repos.id)
#

class Wiki < ApplicationRecord
  acts_as_paranoid
  paginates_per 20
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :resource, polymorphic: true
  belongs_to :repo
  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # 公開状況
  #
  # - hidden  : 非公開
  # - showing : 公開中
  #
  enum status: {
    hidden:  1000,
    showing: 2000
  }
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :title, presence: true
  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:hidden]
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  def switch_status!
    self.hidden? ? self.showing! : self.hidden!
    status
  end
end
