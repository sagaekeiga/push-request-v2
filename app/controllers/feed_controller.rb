class FeedController < ApplicationController
  def index
    @pulls = Pull.order(created_at: :desc)
    respond_to do |format|
      format.rss { render layout: false }
    end
  end
end
