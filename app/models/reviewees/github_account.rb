# == Schema Information
#
# Table name: reviewees_github_accounts
#
#  id                  :bigint(8)        not null, primary key
#  access_token        :string
#  avatar_url          :string
#  company             :string
#  deleted_at          :datetime
#  email               :string
#  html_url            :string
#  location            :string
#  login               :string
#  name                :string
#  nickname            :string
#  public_gists        :integer
#  public_repos        :integer
#  reviewee_created_at :datetime
#  reviewee_updated_at :datetime
#  url                 :string
#  user_type           :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  gravatar_id         :string
#  owner_id            :bigint(8)
#  reviewee_id         :bigint(8)
#
# Indexes
#
#  index_reviewees_github_accounts_on_deleted_at   (deleted_at)
#  index_reviewees_github_accounts_on_reviewee_id  (reviewee_id)
#
# Foreign Keys
#
#  fk_rails_...  (reviewee_id => reviewees.id)
#

class Reviewees::GithubAccount < ApplicationRecord
  acts_as_paranoid
  # -------------------------------------------------------------------------------
  # Validations
  # -------------------------------------------------------------------------------
  validates :owner_id, presence: true, uniqueness: true
  # -------------------------------------------------------------------------------
  # Relations
  # -------------------------------------------------------------------------------
  belongs_to :reviewee
  # -------------------------------------------------------------------------------
  # ClassMethods
  # -------------------------------------------------------------------------------
  def fetch_orgs!
    res_orgs = Github::Request.github_exec_fetch_orgs!(self)
    Rails.logger.debug res_orgs
    res_orgs.each do |res_org|
      res_org =  ActiveSupport::HashWithIndifferentAccess.new(res_org)
      org = Org.find_or_initialize_by(remote_id: res_org[:id])
      org.update_attributes!(
        avatar_url: res_org[:avatar_url],
        description: res_org[:description],
        login: res_org[:login]
      )
      reviewee_org = self.reviewee.reviewee_orgs.new(org: org)
      reviewee_org.set_role(self)
      reviewee_org.save!
    end
  end
end
