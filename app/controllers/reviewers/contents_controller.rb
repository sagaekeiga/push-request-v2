class Reviewers::ContentsController < Reviewers::BaseController
  before_action :set_repo, only: %i(index show)
  before_action :set_content, only: %i(show)
  skip_before_action :verify_authenticity_token, only: %i(search)
  skip_before_action :set_skill!, only: %i(search)
  skip_before_action :authenticate_reviewer!, only: %i(search)

  def index
    @dir_or_files = @repo.contents.top
    @readme = @repo.contents.find_by(name: 'README.md')
  end

  def show
    @dir_or_files = @content.children.sub(@content).decorate
    # respond_to do |format|
    #   format.html
    #   format.json do
    #     render json: {
    #       name: @content.name,
    #       content: @content.content
    #     }
    #   end
    # end
  end

  def search
    repo = Repo.find(params[:repo_id])
    regexp = /#{params[:keyword]}/
    contents = repo.contents.where('content LIKE ?', "%#{Base64.encode64(params[:keyword])}%").pluck(:id, :path, :content) if params[:keyword].present?
    contents.each { |content| content[2] = Base64.decode64(content[2]).force_encoding('UTF-8') }
    contents.each do |content|
      lines = content[2]
      content[2] = []
      lines.each_line do |line|
        content[2] << line if line =~ regexp
      end
    end
    render json: { contents: contents, repo_id: repo.id }
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id]).decorate
  end

  def set_content
    @content = Content.find(params[:id])
  end
end
