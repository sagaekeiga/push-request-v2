class RevieweeMailer < ApplicationMailer
  def invite(owner, member)
    @owner = owner
    @member = member
    mail(subject: '招待されました', to: @member.email)
  end
end
