class ReviewersController < Reviewers::BaseController
  def dashboard
    @pulls = Repo.pulls_suitable_for(current_reviewer).order(created_at: :desc)
  end

  def my_page
    @working_pulls = current_reviewer.pulls.agreed.decorate.select{ |pull| (((Time.at(pull.updated_at) + 2.hours) - Time.now) / 60) > 0 }
    @reviews = current_reviewer.reviews.where(created_at: Time.now.beginning_of_month..Time.now)
  end
end
