class RevieweesController < Reviewees::BaseController
  def dashboard
    @reviewee = current_reviewee.decorate
  end
end
