class ReviewersController < Reviewers::BaseController
  def dashboard
    @pulls = Pull.request_reviewed
  end
end
