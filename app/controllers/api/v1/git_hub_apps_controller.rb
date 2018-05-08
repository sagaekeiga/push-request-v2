#
# GitHubAppからのリクエスト管理
#
class Api::V1::GitHubAppsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # @TODO IP制限かける

  # POST /git_hub_apps/webhook
  def webhook
    git_hub = Users::GitHub.find_by(owner_id: params[:installation][:account][:id])
    response_internal_server_error if git_hub.nil?
    git_hub.user.create_repo!(params[:repositories_added]) if params[:repositories_added].present?
  end
end
