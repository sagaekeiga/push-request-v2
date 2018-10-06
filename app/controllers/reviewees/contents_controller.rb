class Reviewees::ContentsController < Reviewees::BaseController
  before_action :set_repo, only: %i(index show update)
  before_action :set_content, only: %i(show update)
  skip_before_action :verify_authenticity_token, only: %i(update)
  before_action :check_reviweee_identity, only: %i(index show)

  def index
    @dir_or_files = @repo.contents.top
    @readme = @repo.contents.find_by(name: 'README.md')
  end

  def show
    @dir_or_files = @content.children.sub(@content).decorate
  end

  def update
    case @content.status
    when 'hidden'
      @content.showing!
      @content.children.each(&:showing!) if @content.children.present?
    when 'showing'
      @content.hidden!
      @content.children.each(&:hidden!) if @content.children.present?
    end
    render json: { status: @content.status }
  end

  private

  def set_repo
    @repo = Repo.find(params[:repo_id]).decorate
  end

  def set_content
    @content = Content.find(params[:id])
  end
end
