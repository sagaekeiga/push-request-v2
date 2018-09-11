#
# GitHubAppからのリクエスト管理
#
class Api::V1::GithubAppsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # @TODO IP制限かける

  # POST /github_apps/receive_webhook
  def receive_webhook
    case request.headers['X-GitHub-Event']
    when 'installation_repositories', 'installation'
      @github_account = Reviewees::GithubAccount.find_by(owner_id: params[:installation][:account][:id])
      return response_internal_server_error if @github_account.nil?
      # Add
      CreateRepoJob.perform_later(@github_account, params.to_json) if params[:repositories_added].present? || params[:repositories].present?
      # Remove
      if params[:github_app][:repositories_removed].present?
        params[:github_app][:repositories_removed].each do |repositories_removed_params|
          @github_account.reviewee.repos.find_by(remote_id: repositories_removed_params[:id])&.destroy
        end
        status = true
      end
    when 'pull_request'
      @github_account = Reviewees::GithubAccount.find_by(owner_id: params[:github_app][:pull_request][:head][:user][:id])
      status = @github_account.reviewee.pulls.update_by_pull_request_event!(params[:github_app][:pull_request]) if params[:github_app][:pull_request].present?
    when 'pull_request_review'
      status = Review.fetch_remote_id!(params)
    when 'pull_request_review_comment'
      status = ReviewComment.fetch!(params)
    when 'issue_comment'
      @github_account = Reviewees::GithubAccount.find_by(owner_id: params[:issue][:user][:id])
      status = Review.fetch_issue_comments!(params)
    end
    if status.is_a?(TrueClass)
      return response_success(controller_name, action_name)
    else
      return response_internal_server_error
    end
  end
end
