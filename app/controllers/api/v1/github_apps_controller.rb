#
# GitHubAppからのリクエスト管理
#
class Api::V1::GithubAppsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # @TODO IP制限かける

  # POST /github_apps/receive_webhook
  def receive_webhook
    p request.headers['X-GitHub-Event']
    case request.headers['X-GitHub-Event']
    when 'installation_repositories'
      github_account = Reviewees::GithubAccount.find_by(owner_id: params[:installation][:account][:id])
      response_internal_server_error if github_account.nil?
      # Add
      status = github_account.reviewee.repos.create_or_restore!(params[:repositories_added]) if params[:repositories_added].present?
      # Remove
      if params[:github_app][:repositories_removed].present?
        github_account.reviewee.repos.find_by(remote_id: params[:github_app][:repositories_removed][0][:id])&.destroy
        status = true
      end
    when 'pull_request'
      status = Pull.update_by_pull_request_event!(params)
    end
    if status.is_a?(TrueClass)
      return response_success(controller_name, action_name)
    else
      return response_internal_server_error
    end
  end
end
