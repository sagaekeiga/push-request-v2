#
# GitHubAppからのリクエスト管理
#
class Api::V1::GithubAppsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # @TODO IP制限かける

  # POST /github_apps/webhook
  def webhook
    github_account = Reviewees::GithubAccount.find_by(owner_id: params[:installation][:account][:id])
    response_internal_server_error if github_account.nil?
    # Add
    status = github_account.reviewee.repos.create_or_restore!(params[:repositories_added]) if params[:repositories_added].present?
    # Remove
    if params[:repositories_removed].present?
      github_account.reviewee.repos.find_by(remote_id: params[:repositories_removed][0][:id])&.destroy
      status = true
    end
    if status.is_a?(TrueClass)
      response_success(controller_name, action_name)
    else
      response_internal_server_error
    end
  end
end
