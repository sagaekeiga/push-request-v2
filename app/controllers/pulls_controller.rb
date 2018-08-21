class PullsController < ApplicationController
  before_action :set_pull, only: %i(show update files)
  before_action :set_changed_files, only: %i(show files)

  def show
    @pull = Pull.includes(changed_files: :review_comments).order('review_comments.created_at asc').friendly.find(params[:token])
    @double_review_comments = @pull.changed_files.map{ |changed_file| changed_file.review_comments }
  end

  def files
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:token] || params[:pull_token])
  end

  def set_changed_files
    @changed_files = @pull.last_committed_changed_files.decorate
  end
end
