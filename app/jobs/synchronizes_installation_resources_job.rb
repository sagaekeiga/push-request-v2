class SynchronizesInstallationResourcesJob < ApplicationJob
  queue_as :default

  def perform(github_account)
    Repo.check_installation_repositories(github_account)
  end
end
