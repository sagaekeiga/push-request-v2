#
# GitHubAppからのリクエスト管理
#
class Api::V1::GithubAppsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # @TODO IP制限かける

  # POST /github_apps/receive_webhook
  def receive_webhook
    begin
      github_account = Reviewees::GithubAccount.find_by(owner_id: params[:installation][:account][:id])
      response_internal_server_error if github_account.nil?
      # Add
      status = github_account.reviewee.repos.create_or_restore!(params[:repositories_added]) if params[:repositories_added].present?
      # Remove
      if params[:github_app][:repositories_removed].present?
        github_account.reviewee.repos.find_by(remote_id: params[:github_app][:repositories_removed][0][:id])&.destroy
        status = true
      end
    rescue => e
      Rails.logger.error e
      Rails.logger.error e.backtrace.join("\n")
      # Update
      status = Pull.check_and_update!(params[:github_app][:check_suite]) if params[:github_app][:check_suite].present?
    end
    if status.is_a?(TrueClass)
      return response_success(controller_name, action_name)
    else
      return response_internal_server_error
    end
  end
end
