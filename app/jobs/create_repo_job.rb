class CreateRepoJob < ApplicationJob
  queue_as :default

  def perform(params)
    Repo.fetch!(ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(params)))
  end
end
