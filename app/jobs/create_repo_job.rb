class CreateRepoJob < ApplicationJob
  queue_as :default

  def perform(params)
    Repo.fetch!(JSON.parse(params))
  end
end
