class ConnectsController < Users::BaseController
  # GET /auth/github/callback
  def github
    callback_from :github
  end

  # GET /auth/facebook/callback
  def callback_from(_provider)
    ActiveRecord::Base.transaction do
      @user = current_user.connect_to_github(request.env['omniauth.auth'])
    end
    redirect_to users_dashboard_url
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    redirect_to new_user_registration_url, danger: (t 'views.failed', resource: I18n.t('activerecord.models.github_info'))
  end
end
