class ConnectsController < Reviewees::BaseController
  skip_before_action :connect_github!
  # GET /auth/github/callback
  def github
    callback_from :github
  end

  # GET /auth/facebook/callback
  def callback_from(_provider)
    ActiveRecord::Base.transaction do
      @reviewee = current_reviewee.connect_to_github(request.env['omniauth.auth'])
    end
    redirect_to reviewees_repos_url, success: t('views.github.connect.success')
  rescue => e
    Rails.logger.error e
    Rails.logger.error e.backtrace.join("\n")
    redirect_to new_reviewee_registration_url, danger: (t 'views.failed', resource: I18n.t('activerecord.models.github_info'))
  end
end
