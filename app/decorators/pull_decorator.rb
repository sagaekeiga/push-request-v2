class PullDecorator < ApplicationDecorator
  delegate_all
  # GitHub上のプルリクエストへのリンクを返す
  def remote_url
    Settings.github.web_domain + object.repo&.full_name + '/pull/' + object.number&.to_s
  end

  # レビュイーページのステータスを返す
  def status_title_for_reviewee
    if object.completed?
      I18n.t('views.status.completed')
    else
      I18n.t('views.status.pending')
    end
  end

  # プルのステータスに基づき次のアクション名を返す
  def link_title_by_status
    case object.status
    when 'request_reviewed', 'canceled'
      I18n.t('reviewers.views.reviews')
    when 'agreed'
      I18n.t('reviewers.views.cancels')
    end
  end

  # プルのステータスに基づきボタンカラーを返す
  def btn_class_by_status
    case object.status
    when 'request_reviewed', 'canceled'
      'btn-primary'
    when 'agreed'
      'btn-danger'
    end
  end
end
