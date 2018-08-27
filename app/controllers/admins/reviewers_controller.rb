class Admins::ReviewersController < Admins::BaseController
  def show
    @reviewer = Reviewer.find(params[:id])
  end
end
