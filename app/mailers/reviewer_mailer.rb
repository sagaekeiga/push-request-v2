class ReviewerMailer < ApplicationMailer
  def comment(review_comment)
    @review_comment = review_comment
    @reviewer = review_comment.reviewer
    @pull = review_comment.changed_file.pull
    mail(subject: t('.title'), to: @reviewer.email)
  end
end
