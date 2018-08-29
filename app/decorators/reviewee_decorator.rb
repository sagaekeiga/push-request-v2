class RevieweeDecorator < ApplicationDecorator
  delegate_all
  def ok_git
    github_account ? 'ok' : ''
  end

  def ok_repo
    repos.present? && pulls.present? ? 'ok' : ''
  end

  def ok_req
    pulls.present? && pulls.where(status: %i(request_reviewed agreed reviewed)).present? ? 'ok' : ''
  end
end
