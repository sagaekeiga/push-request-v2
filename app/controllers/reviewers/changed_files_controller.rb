class Reviewers::ChangedFilesController < Reviewers::BaseController
  def show
    @pull = Pull.friendly.find(params[:pull_token])
    @changed_file = @pull.changed_files.find(params[:id])
    @res = @changed_file.github_exec_fetch_content!
  end
end
