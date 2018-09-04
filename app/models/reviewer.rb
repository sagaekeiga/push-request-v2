# == Schema Information
#
# Table name: reviewers
#
#  id                     :bigint(8)        not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  status                 :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_reviewers_on_deleted_at            (deleted_at)
#  index_reviewers_on_email                 (email) UNIQUE
#  index_reviewers_on_reset_password_token  (reset_password_token) UNIQUE
#

class Reviewer < ApplicationRecord
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  has_many :reviews
  has_many :review_comments
  has_many :skillings, dependent: :destroy, as: :resource
  has_many :skills, through: :skillings
  has_many :pulls
  has_one :github_account, class_name: 'Reviewers::GithubAccount'
  accepts_nested_attributes_for :skillings, allow_destroy: true

  # -------------------------------------------------------------------------------
  # Enumerables
  # -------------------------------------------------------------------------------
  # ステータス
  #
  # - pending         : 登録済み（承認待ち）
  # - active          : 活動中
  # - rejected        : 非承認済み
  # - quit            : 退会済み
  #
  enum status: {
    pending:  1000,
    active:   2000,
    rejected: 3000,
    quit:     4000
  }

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:pending]

  # -------------------------------------------------------------------------------
  # Attributes
  # -------------------------------------------------------------------------------
  attribute :status, default: statuses[:pending]

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  # pullのレビューコメントを返す
  def target_review_comments(pull)
    review_comments.where(changed_file: pull.changed_files).where.not(reviewer: nil)
  end

  # レビューコメントを削除する
  def cancel_review_comments!(pull)
    if target_review_comments(pull).present?
      target_review_comments(pull).delete_all
    end
  end

  # GitHub連携をする
  def connect_to_github(auth)
    reviewer_github_account = build_github_account(
      login: auth['extra']['raw_info']['login'],
      owner_id: auth['extra']['raw_info']['id'],
      avatar_url: auth['extra']['raw_info']['avatar_url'],
      gravatar_id: auth['extra']['raw_info']['gravatar_id'],
      email: auth['info']['email'],
      url: auth['info']['url'],
      html_url: auth['extra']['raw_info']['html_url'],
      user_type: auth['extra']['raw_info']['type'],
      nickname: auth['info']['nickname'],
      name: auth['info']['name'],
      company: auth['info']['company'],
       location: auth['extra']['raw_info']['location'],
      public_gists: auth['extra']['raw_info']['public_gists'],
      public_repos: auth['extra']['raw_info']['public_repos'],
      reviewee_created_at: auth['extra']['raw_info']['created_at'],
      reviewee_updated_at: auth['extra']['raw_info']['updated_at']
    )
    reviewer_github_account.save!
  end
end
