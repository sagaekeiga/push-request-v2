class Reviewees::BaseController < ApplicationController
  before_action :authenticate_reviewee!

  def check_reviweee_identity
    @other = true unless @repo.reviewee?(current_reviewee) || @repo.reviewee_org?(current_reviewee) || @repo.membership?(current_reviewee)
  end
end
