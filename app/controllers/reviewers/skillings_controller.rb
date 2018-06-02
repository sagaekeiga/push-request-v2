class Reviewers::SkillingsController < Reviewers::BaseController
  skip_before_action :set_skill!
  skip_before_action :connect_github!

  def edit
    @reviewer = current_reviewer
  end

  def update
    if current_reviewer.update(reviewer_params)
      redirect_to reviewers_dashboard_url, success: t('.success')
    else
      render :edit
    end
  end

  private

  def reviewer_params
    params.require(:reviewer).permit(
      skill_ids: []
    )
  end
end
