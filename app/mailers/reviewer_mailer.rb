class ReviewerMailer < ApplicationMailer
  # GitHub上でレビュイーがコメントした時
  def comment(review_comment)
    @review_comment = review_comment
    @reviewer = review_comment.reviewer
    @pull = review_comment.changed_file.pull
    mail(subject: t('.title'), to: @reviewer.email)
  end

  def issue_comment(review)
    @review = review
    @reviewer = review.pull.reviewer
    @pull = review.pull
    mail(subject: t('.title'), to: @reviewer.email)
  end
end
