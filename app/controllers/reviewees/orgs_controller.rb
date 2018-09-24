class Reviewees::OrgsController < Reviewees::BaseController
  before_action :set_org, only: %i(update)
  def index
    @orgs = current_reviewee.orgs.owner
  end

  def update
    if @org.is_valid?
      @org.is_invalid!
    else
      @org.is_valid!
    end
    @orgs = current_reviewee.orgs
    redirect_to :reviewees_orgs, success: '更新しました'
  end

  private

  def set_org
    @org = current_reviewee.orgs.find(params[:id])
  end
end
