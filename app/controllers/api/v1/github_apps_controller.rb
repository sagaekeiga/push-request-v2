#
# GitHubAppからのリクエスト管理
#
class Api::V1::GithubAppsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # @TODO IP制限かける

  # POST /github_apps/webhook
  def webhook
    github_account = Users::GithubAccount.find_by(owner_id: params[:installation][:account][:id])
    response_internal_server_error if github_account.nil?
    # Add
    status = github_account.user.repos.create_or_restore!(params[:repositories_added]) if params[:repositories_added].present?
    # Remove
    if params[:repositories_removed].present?
      repo = github_account.user.repos.find_by(remote_id: params[:repositories_removed][0][:id])&.destroy
      status = true
    end
    if status.is_a?(TrueClass)
      response_success(controller_name, action_name)
    else
      response_internal_server_error
    end
  end
end
