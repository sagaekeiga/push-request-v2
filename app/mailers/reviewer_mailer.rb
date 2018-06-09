class ReviewerMailer < ApplicationMailer
  def notice_comment_by_reviewee(review_comment)
    mail(subject: t('.title'), to: review_comment.email) if resource.email
  end
end
