class ReviewersController < Reviewers::BaseController
  def dashboard
    @pulls = Pull.where(status: :request_reviewed || :canceled)
  end
end
