class UsersController < Users::BaseController
  def dashboard
  end

  def pulls
    @pulls = current_user.pulls
  end

  def repos
  end
end
