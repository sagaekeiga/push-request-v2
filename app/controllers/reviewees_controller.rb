class RevieweesController < Reviewees::BaseController
  def dashboard
  end

  def pulls
    @pulls = current_reviewee.pulls
  end

  def repos
  end
end
