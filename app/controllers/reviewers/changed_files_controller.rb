class Reviewers::ChangedFilesController < Reviewers::BaseController
  before_action :set_pull, only: %i(index show)
  before_action :set_changed_files, only: %i(index)

  def index
  end

  def show
    @pull = Pull.friendly.find(params[:pull_token])
    @changed_file = @pull.changed_files.find(params[:id])
    @res = @changed_file.github_exec_fetch_content!
  end

  private

  def set_pull
    @pull = Pull.friendly.find(params[:pull_token]).decorate
  end

  def set_changed_files
    @changed_files = @pull.files_changed.decorate
  end
end
