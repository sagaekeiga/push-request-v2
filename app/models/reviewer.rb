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

  # -------------------------------------------------------------------------------
  # InstanceMethods
  # -------------------------------------------------------------------------------
  # pullのレビューコメントを返す
  def target_review_comments(pull)
    review_comments.where(changed_file: pull.changed_files)
  end

  # レビューコメントを削除する
  def cancel_review_comments!(pull)
    if current_reviewer.target_review_comments(pull).present?
      target_review_comments(pull).delete_all
    end
  end
end
