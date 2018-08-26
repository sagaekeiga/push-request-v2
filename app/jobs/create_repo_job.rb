class CreateRepoJob < ApplicationJob
  queue_as :default

  def perform(github_account, params)
    github_account.reviewee.repos.fetch!(JSON.parse(params))
  end
end
