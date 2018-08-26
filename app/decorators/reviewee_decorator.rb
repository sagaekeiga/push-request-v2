class RevieweeDecorator < ApplicationDecorator
  delegate_all
  def ok_git
    github_account ? 'ok' : ''
  end

  def ok_repo
    repos ? 'ok' : ''
  end

  def ok_req
    pulls && pulls.where.not(status: :connected) ? 'ok' : ''
  end
end
