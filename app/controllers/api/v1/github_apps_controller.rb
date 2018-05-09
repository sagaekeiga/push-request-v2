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
    status = github_account.user.create_repo!(params[:repositories_added]) if params[:repositories_added].present?
    if status.is_a?(TrueClass)
      response_success(controller_name, action_name)
    else
      response_internal_server_error
    end
  end
end
