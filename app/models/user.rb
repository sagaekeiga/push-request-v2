# == Schema Information
#
# Table name: users
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
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

   # -------------------------------------------------------------------------------
   # Relations
   # -------------------------------------------------------------------------------
   has_one :github_account, class_name: 'Users::GithubAccount'
   has_many :repos
   has_many :pulls

   def connect_to_github(auth)
     user_github_account = build_github_account(
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
       user_created_at: auth['extra']['raw_info']['created_at'],
       user_updated_at: auth['extra']['raw_info']['updated_at']
     )
     user_github_account.save!
   end
end
