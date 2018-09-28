class RevieweeMailer < ApplicationMailer
  def invite(owner, member)
    @owner = owner
    @member = member
    @encode_member = JsonWebToken.encode({ 'member_id': @member.id })
    @encode_owner = JsonWebToken.encode({ 'owner_id': @owner.id })
    mail(subject: "#{@owner.login} さんから招待されています", to: @member.email)
  end
end
