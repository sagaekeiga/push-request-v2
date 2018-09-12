class FetchContentJob < ApplicationJob
  queue_as :default

  def perform(repo)
    Content.fetch!(repo)
  end
end
