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

  # プルのステータスに基づきボタンカラーを返す
  def btn_class_by_status
    case object.status
    when 'connected'
      'btn-outline-primary'
    when 'request_reviewed', 'reviewed'
      'btn-success'
    when 'completed'
      'btn-warning'
    end
  end

  # 残り時間を返す
  def remaining_time
    sum_minutes = ((Time.at(updated_at) + 2.hours) - Time.now) / 60
    if (sum_minutes / 60)&.floor == 0
      I18n.t 'reviewers.my_page.unit_minutes', working_hours: (sum_minutes % 60)&.floor.to_s
    else
      I18n.t 'reviewers.my_page.unit_hour_and_minutes', working_hours: (sum_minutes / 60)&.floor.to_s, working_minutes: (sum_minutes % 60)&.floor.to_s
    end
  end

  def back_path
    h.file_reviewers_pull_reviews_path(object)
  end

  # ブランチ差分
  def files_changed_count
    files_changed.count
  end

  # コミット数
  def commits_count
    commits.count
  end
end
