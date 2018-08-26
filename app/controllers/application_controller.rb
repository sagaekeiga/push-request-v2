class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger
  before_action :check_reviewer

  # 200 Success
  def response_success(class_name, action_name)
    render status: 200, json: { status: 200, message: "Success #{class_name.capitalize} #{action_name.capitalize}" }
  end

  # 400 Bad Request
  def response_bad_request
    render status: 400, json: { status: 400, message: 'Bad Request' }
  end

  # 401 Unauthorized
  def response_unauthorized
    render status: 401, json: { status: 401, message: 'Unauthorized' }
  end

  # 404 Not Found
  def response_not_found(class_name = 'page')
    render status: 404, json: { status: 404, message: "#{class_name.capitalize} Not Found" }
  end

  # 409 Conflict
  def response_conflict(class_name)
    render status: 409, json: { status: 409, message: "#{class_name.capitalize} Conflict" }
  end

  # 500 Internal Server Error
  def response_internal_server_error
    render status: 500, json: { status: 500, message: 'Internal Server Error' }
  end

  def transition_dashboard!
    redirect_to reviewers_dashboard_url if reviewer_signed_in?
    redirect_to reviewees_dashboard_url if reviewee_signed_in?
  end

  rescue_from Exception,                        with: :render_500
  rescue_from ActiveRecord::RecordNotFound,     with: :render_404
  rescue_from ActionController::RoutingError,   with: :render_404

  def render_404(e = nil)
    logger.info "Rendering 404 with exception: #{e.message}" if e

    format = params[:format] == :json ? :json : :html
    render template: 'errors/error_404', status: 404, layout: 'lp', content_type: 'text/html'
  end

  def render_500(e = nil)
    if e
      logger.error "Rendering 500 with exception: #{e.message}"
      logger.error e.backtrace.join("\n")
    end
    render template: 'errors/error_500', status: 500, layout: 'lp', content_type: 'text/html'
  end

  force_ssl if: :use_ssl?

  def check_reviewer
    redirect_to :reviewers_pending if reviewer_signed_in? && current_reviewer.github_account && current_reviewer.skillings && current_reviewer.pending?
  end

  #
  # 本番環境かどうかを返す
  #
  def use_ssl?
    Rails.env.production?
  end
end
