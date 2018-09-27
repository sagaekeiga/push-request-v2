class Reviewees::MembershipsController < Reviewees::BaseController
  skip_before_action *%i(verify_authenticity_token authenticate_reviewee!), only: %i(create suggest)
  before_action :set_membership, only: %i(join update)
  def index
    @members = current_reviewee.members.includes(:github_account)
  end

  def create
    github_account = Reviewees::GithubAccount.find(params[:github_account_id])
    member = github_account.reviewee
    membership = Membership.new(owner_id: current_reviewee.id, member_id: member.id)
    membership.save
    owner = Reviewee.find(membership.owner_id)
    RevieweeMailer.invite(owner, member).deliver_later
    render json: { message: 'created' }
  end

  def destroy
    member = Reviewee.find(params[:reviewee_id])
    membership = Membership.find_by(owner_id: current_reviewee.id, member_id: member.id)
    membership.destroy
    redirect_to :reviewees_memberships, success: '削除しました'
  end

  def suggest
    reviewees = Reviewee.includes(:github_account).where.not(id: current_reviewee.id).where('email LIKE ?', "#{params[:keyword]}%").select{ |reviewee| reviewee.github_account.present? }.first(10)
    return render json: { reviewees: [] } if reviewees.nil?
    github_accounts = reviewees.map(&:github_account)
    render json: { github_accounts: github_accounts }
  end

  def join
    @owner = Reviewee.find(params[:owner_id])
  end

  def update
    @membership = Membership.find(params[:id])
    @membership.agreed!
    redirect_to :reviewees_dashboard, success: '参加しました'
  end

  private

  def set_membership
    @membership = Membership.find_by(
      owner_id: params[:owner_id],
      member_id: params[:member_id]
    )
  end
end
